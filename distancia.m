function fun=distancia(dist,sol)
dist=ceil(dist);
M=size(dist,1);
suma=0;
for i=1:M
    suma=dist(sol(i),sol(i+1))+suma;
end
fun=suma;
end
