#define n 3

byte flag[n];
byte someInCS;
bool inCS[n];
int x;
int y;

proctype process(byte i) {
    do
    :: i <= 2 -> {
        printf("MSC: in non-critical\n");
    }
    :: true -> {
        do
        :: true -> {
            flag[i] = 1;
            x = i;
            if
            :: (y != -1) ->
                flag[i] = 0;
                do
                :: y != -1 -> skip;
                :: else -> break;
                od;
                skip;
            :: else -> {
                y = i;
                if
                :: (x == i) ->
                    break;
                :: else ->
                    flag[i] = 0;
                    byte j = 0;
                    do
                    :: j < n -> {
                        do
                        :: flag[j] != 0 -> skip;
                        :: else -> break;
                        od;
                        j = j + 1;
                    }
                    :: else -> break;
                    od;
                    if
                    :: (y == i) ->
                        break;
                    :: else ->
                        do
                        :: y != -1 -> skip;
                        :: else -> break;
                        od;
                        skip;
                    fi;
                fi;
            }
            fi;
        }
        od;

        atomic {
            someInCS++;
            inCS[i] = true;
            printf("MSC: in critical\n");
        }

        atomic {
            y = -1;
            someInCS--;
            inCS[i] = false;
            printf("MSC: release mutex\n");
        }

        flag[i] = 0;
    }
    od;
}

init {
    x = -1;
    y = -1;
    someInCS = 0;

    byte k = 0;
    atomic {
        do
        :: k < n -> {
            flag[k] = 0;
            inCS[k] = false;
            run process(k);
            k++;
        }
        :: else -> break;
        od;
    }
}
