#define procAmount 2
#define procId (_pid - 1)

typedef Semaphore {
    byte count = 1;
    chan queue = [procAmount] of { byte };
    bool blocked[procAmount];
};

inline wait(S) {
    atomic {
        printf("MSC: acquire sem\n");
        if
        :: S.count == 1 -> S.count = 0;
        :: else -> {
            S.queue!procId;
            S.blocked[procId] = true;
            !S.blocked[procId];
        }
        fi;
    }
};

inline signal(S) {
    atomic {
        byte next = 0;
        if
        :: len(S.queue) > 0 -> 
            S.queue?next;
            S.blocked[next] = false;
            printf("MSC: %d removed from queue\n", next);
        :: else -> S.count = 1;
        fi;
        printf("MSC: released sem\n");
    }
};

Semaphore sem;

proctype proc() {
    do
    :: procId <= procAmount -> printf("MSC: in non-cs\n");
    :: true ->
        aq: wait(sem);
        cs: printf("MSC: in cs\n");
        signal(sem);
    od;
};

init {
    atomic {
        run proc();
        run proc();
    }
};
