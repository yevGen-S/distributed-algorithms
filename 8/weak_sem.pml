#define procAmount 2
#define procId (_pid - 1)

typedef Semaphore {
    byte count = 1;
    bool blocked[procAmount];
};

inline wait(S) {
    atomic {
        printf("MSC: acquire sem\n");
        if
        :: S.count == 1 -> S.count = 0;
        :: else -> {
            S.blocked[procId] = true;
            !S.blocked[procId];
        }
        fi;
    }
};

inline signal(S) {
    atomic {
        if
        :: S.blocked[0] -> S.blocked[0] = false;
        :: S.blocked[1] -> S.blocked[1] = false;
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
