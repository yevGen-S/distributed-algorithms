#define N 3
#define CRIT 10

bool FLAG[N];
int TURN[N];

inline maximum(max) {
    int k = 0;
    do
    :: k < N -> {
        if
        :: max < TURN[k] ->  max = TURN[k];
         :: else -> {
            skip;
        }
        fi;
        k++;
    }
    :: else -> {
        break;
    }
    od;
}

inline compare(i, j, res) {
    if 
    :: TURN[i] < TURN[j] -> res = true;
    :: TURN[i] > TURN[j] -> res = false;
    :: else -> {
        if
        :: i < j -> {
            res = true;
        }
        :: else -> {
            res = false;
        }
        fi;
    }
    fi;
}

inline block_until_all_pass() {
    int p = 0;
    do
    :: p < N -> {
        TURN[p] == 0;
        p++;
    }
    :: else -> {
        break;
    }
    od;
}

inline acquire_mutex(i) {
    atomic {
        printf("MSC: acquire mutex\n");
        FLAG[i] = 1;
    }
    int max = 0;
    maximum(max);

    if
    :: max >= CRIT -> {
        block_until_all_pass();
        max = 0;
    }
    :: else -> {
        skip;
    }
    fi;

    TURN[i] = max + 1;
    printf("MSC: ticket: %d\n", TURN[i]);
    FLAG[i] = 0;
    int j = 0;
    do
    :: (j < N) && (j != i) -> {
        FLAG[j] != 1;
        bool is_turn = TURN[j] != 0;
        bool is_priority = false;
        do
        :: TURN[j] != 0 -> {
            compare(i, j, is_priority);
            if
            :: !is_priority -> {
                skip;
            }
            :: else -> {
                break;
            }
            fi;
        }
        :: else -> {
            break;
        }
        od;
        j++;
    }
    :: j == i -> {
        j++;
    }
    :: else -> {
        break;
    }
    od;
}

inline release_mutex(i) {
    atomic {
        printf("MSC: release mutex\n");
        TURN[i] = 0;
    }
}

proctype proc(int number) {
    do
    :: number < N -> {
        printf("MSC: in non-cs\n");
    }
    :: true -> {
        acquire_mutex(number);
        cs: printf("MSC: in cs\n");
        release_mutex(number);
    }
    od;
}

init {
    int i = 0;
    do
    :: i < N -> {
        run proc(i);
        i++;
    }
    :: else -> {
        break;
    }
    od;
}
