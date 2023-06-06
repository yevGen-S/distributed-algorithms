#define n 3

byte currentQueueNum = 0;
byte nextProcNumInQueue = 0;
bool inCS[n];
bool FLAG[n];

proctype proc(byte i) {
    printf("MSC: started");
    byte procNumInQueue;
    do
    :: i <=n -> skip;
    :: true ->
        FLAG[i] = true;
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
            inCS[i] = true;
        }
   
        atomic{
            FLAG[i] = false;
            inCS[i] = false;
            atomic{
                currentQueueNum++;
                if
                :: currentQueueNum >= n -> currentQueueNum = 0;
                :: else -> skip;
                fi;
            }
            printf("release");
        };
       
        
    od;
}

init {
    byte i = 0;
    do
        :: i < n -> {
            inCS[i] = false;
            FLAG[i]= false;
            run proc(i);
            i++;
        };
        :: else -> break;
    od;
}