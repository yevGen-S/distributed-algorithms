int np = 0;
int nq = 0;

proctype p() {
    int temp = 0;
    do
        :: 1 == 1 -> skip;
        :: true -> {
            np = 1;
            temp = nq;
            atomic {
                np = temp + 1;
                printf("MSC: np = %d\n", np);
            }
            do
                :: nq == 0 || np <= nq -> break;
                :: else -> skip;
            od;
            cs_p: printf("MSC: critical section\n");
            np = 0;
        }
    od
}

proctype q() {
    int temp = 0;
    do
        :: 1 == 1 -> skip;
        :: true -> {
            nq = 1;
            temp = np;
            atomic {
                nq = temp + 1;
                printf("MSC: nq = %d\n", nq);
            }
            
            do
                :: np == 0 || nq < np -> break;
                :: else -> skip;
            od;
            cs_q: printf("MSC: critical section\n");
            nq = 0;
        }
    od
}

init {
    atomic {
        run p();
        run q();
    }
}
