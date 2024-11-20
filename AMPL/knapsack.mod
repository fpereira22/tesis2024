set ELEMENTOS;                  # Index range for items

param PESOMAX integer, >= 1;  # Maximum weight allowed
param VALOR{ELEMENTOS} >= 0;    # Value of items
param PESO{ELEMENTOS} >= 0;   # Weight of items

param acum_peso default 0; # for output
param accum_valor default 0;  # ibid.

var take{ELEMENTOS} binary; # 1 if we take item i; 0 otherwise

# Objective: maximize total value
maximize MaxVal:
         sum{i in ELEMENTOS} VALOR[i] * take[i];

#  Weight restriction
subject to Peso: 
        sum{i in ELEMENTOS} PESO[i] * take[i] <= PESOMAX;