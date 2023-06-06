#define N 2

bool FLAG[N];
bool p0_in_critical;
bool p1_in_critical;

int AFTER_YOU;

proctype process(int number) {
    do
    :: number <= 1 -> printf("MSC: p%d in no critical section\n", number)
    :: true -> 
        FLAG[number] = true;
        AFTER_YOU = number;
        do
        :: (FLAG[1 - number] == true) && (AFTER_YOU == number) -> skip
        :: else -> break;
        od;
        atomic {
            if
                :: number == 0 -> p0_in_critical = true;
                :: number == 1 -> p1_in_critical = true;
            fi;
            printf("MSC: p%d in critical section\n", number);
         
        }
        atomic {
            FLAG[number] = false;
            if
                :: number == 0 -> p0_in_critical = false;
                :: number == 1 -> p1_in_critical = false;
            fi;
            printf("MSC: p%d in no critical section\n", number)
        }
    od;
}

init {
    FLAG[0] = false;
    FLAG[1] = false;

    p0_in_critical = false;
    p1_in_critical = false;

    AFTER_YOU = 0;

    atomic {
        run process(0);
        run process(1);
    }
}