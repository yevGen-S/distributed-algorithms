#define n 3

byte currentQueueNum = 0;
byte nextProcNumInQueue = 0;
byte someInCS = 0;

proctype proc(byte i) {
    printf("MSC: started");
    byte procNumInQueue;
    do
    :: i <=n -> skip;
    :: true ->
        atomic{
            procNumInQueue = nextProcNumInQueue;
            nextProcNumInQueue++;
            if
            :: nextProcNumInQueue >= n -> nextProcNumInQueue = 0;
            :: else -> skip;
            fi;
        };
       
        do
        :: currentQueueNum != procNumInQueue -> skip;
        :: else -> break;
        od;

        atomic{
            printf("MSC: in critical\n");
            someInCS++;
        }

        atomic{
            someInCS--;
            atomic{
                currentQueueNum++;
                if
                :: currentQueueNum >= n -> currentQueueNum = 0;
                :: else -> skip;
                fi;
            }
        };
       
        
    od;
}

init {
    byte i = 0;
    do
        :: i < n -> {
            run proc(i);
            i++;
        };
        :: else -> break;
    od;
}
