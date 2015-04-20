while [ 1 -eq 1 ];
do
    dpctl dump-flows tcp:127.0.0.1:6634 | wc;
    dpctl dump-flows tcp:127.0.0.1:6634;
    sleep 1;
done
