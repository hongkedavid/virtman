#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <strings.h>
#include <string.h>
#include <netdb.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/select.h>
#include <sys/time.h>

const int BUFFER_SIZE = 1448;

int get_random_no(int n)
{
    int rand_no = 0;
    static int rand_init = 0;
    if (!rand_init) {
        srand ((unsigned int)time (0));
        rand_init = 1;
    }
    rand_no = rand();
    rand_no = rand_no % n;

    return rand_no;
}

char get_random_char()
{
    const int max_char_val = 1 << 8;
    int radn;

    radn = get_random_no(max_char_val);
    return (char)radn;
}

int main(int argc, char**argv) {

    if (argc != 5) {
        printf("client <ip address of server> <start port> <end port> <output file>\n");
        exit(0);
    }

    printf("Server ip: %s, port: %s\n", argv[1], argv[2]);
    FILE* outfile = fopen(argv[4], "a");

    int len;
    int cliSock;
    char buf[BUFFER_SIZE];
    struct sockaddr_in servAddr;
    struct timeval time, wait;
    int i, j;

    for (i = 0; i < BUFFER_SIZE; i++) {
         buf[i] = get_random_char();
    }
	
    int k = 0;
    for (i = atoi(argv[2]); i < atoi(argv[3]); i++)
    {
        memset((char *)&servAddr, 0, sizeof(servAddr));
        if (inet_aton(argv[1], &(servAddr.sin_addr)) == 0) { //convert an IP string to network structure
	    printf("inet_aton() failed\n");
            exit(0);
        }
        servAddr.sin_port = htons(i);
	servAddr.sin_family = AF_INET;

	cliSock = socket(AF_INET, SOCK_DGRAM, 0);
	if (cliSock < 0) {
            printf("Cannot create socket\n");
            continue; //exit(0);
        }
        //setsockopt(cliSock, SOL_SOCKET, SO_SNDBUF, (char*)buf, BUFFER_SIZE);
        int send_min_size = 1448;
        int flag = setsockopt(cliSock, SOL_SOCKET, SO_RCVLOWAT, (void *)&send_min_size, sizeof(int));

      //int k1 = 0;
      //for (k1 = 0; k1 < 2; k1++) {
        j = 0;
        len = sizeof(servAddr);

        while (j <= 0) {
           gettimeofday(&time, NULL);
           j = sendto(cliSock, buf, BUFFER_SIZE, 0, (struct sockaddr*)&servAddr, sizeof(servAddr));
	   if (j > 0) {
               fprintf(outfile, "Port %d send time: %ld.%06ld\n", i, time.tv_sec, time.tv_usec);
           }
           else if (j < 0) {
               printf("Send Error\n");
               exit(0);    
           }
        }  
       //}
//        gettimeofday(&wait, NULL);
//        while ((wait.tv_sec-time.tv_sec)*1000000 + (wait.tv_usec-time.tv_usec) < 500)  
//             gettimeofday(&wait, NULL);
        k++;
        if (k > 3) 
           {k=0; usleep(80);}  //200
    }

    close(cliSock);
}

