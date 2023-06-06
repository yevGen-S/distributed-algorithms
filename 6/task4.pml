byte AFTER_YOU;

bool p0_in_critical;
bool p1_in_critical;

proctype process(int number){
    do
    :: number <= 1 -> printf("MSC: p%d in no critical section\n", number);
    :: true -> {
        atomic{
            AFTER_YOU = number;
            printf("MSC: p%d acquire mutex\n", number);   
        }  
        do
        :: AFTER_YOU == number -> skip;
        :: else -> break;
        od;
        atomic{
            if
            :: number == 0 -> p0_in_critical = true;
            :: number == 1 -> p1_in_critical = true;
            fi;
            printf("MSC: p%d in critical section\n", number);
        }
        
        atomic{
            if
            :: number == 0 -> p0_in_critical = false;
            :: number == 1 -> p1_in_critical = false;
            fi;
            printf("MSC:  p%d  release mutex\n", number);
        }
        
    }
    od
}

init{
    atomic{
        AFTER_YOU = -1;
        
        p0_in_critical = false;
        p1_in_critical = false;

        run process(0);
        run process(1);
    }
}