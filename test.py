

d = {i:i**2 for i in range(1, 5)}

for i, j in d.items():
    print(i, j)
    d[i] = i+1
    d[i+1] = i+2