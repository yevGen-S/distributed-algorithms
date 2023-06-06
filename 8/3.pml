#define buffSize 5
#define procAmount 2
#define procId (_pid - 1)
#define maxItems 25

typedef Free {
    byte count = buffSize;
    bool blocked[procAmount];
    bit type = 0;
};

typedef Busy {
    byte count = 0;
    bool blocked[procAmount];
    bit type = 1;
};

int buffer[buffSize];
Free free;
Busy busy;

inline up(S) {
    atomic {
        printf("MSC: enter up\n");
        if
        :: S.blocked[0] -> S.blocked[0] = false;
        :: S.blocked[1] -> S.blocked[1] = false;
        :: else -> S.count++;
        fi;
        printf("MSC: leave up\n");
    }
};

inline down(S) {
    atomic {
        printf("MSC: enter down\n");
        if
        :: S.count > 0 -> {
            S.count--;
        };
        :: else -> {
            S.blocked[procId] = true;
            !S.blocked[procId];
        }
        fi;
        printf("MSC: leave down\n");
    }
};

proctype producer() {
    int nextItemId = 1;
    byte inIndex = 0;
    do
    :: nextItemId < maxItems -> 
        downLabelProducer: down(free);
        printf("MSC: next item = %d\n", nextItemId);
        producerBuf: buffer[inIndex] = nextItemId;
        nextItemId++;
        inIndex = (inIndex + 1) % buffSize;
        up(busy);
    :: else -> break;
    od;
}

int prevItemId = -1;
int gotItemId = 0;
proctype consumer() {
    byte outIndex = 0;

    do
    :: gotItemId < maxItems - 1 ->
        downLabelConsumer: down(busy);
        consumerBuf: atomic{
            prevItemId = gotItemId;
            gotItemId = buffer[outIndex];
        }
        printf("MSC: got item with id %d\n", gotItemId);
        outIndex = (outIndex + 1) % buffSize;
        up(free);
    
    :: else -> break;
    od;
}

init {
    byte i = 0;
    do
        :: i < procAmount -> {
            free.blocked[i] = false;
            busy.blocked[i] = false;
            i++;
        }
        :: else -> break;
    od;
    atomic {
        run producer();
        run consumer();
    }
}
