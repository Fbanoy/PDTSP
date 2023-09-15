function [Rbest,bestdist,distance,Time,W]=PDTSP_VND(Minutes,data,Q,Dist,Nexp,Nrand)
tic
W=1;
%Solucion inicial
while W ~= 0
    [R,distance,~,W]= PDTSP_GARSP3(data,Q,Dist,Nexp,Nrand);
end
j=1;

Rbest=R; %para guardar resultados
Rbesttemp=R;
seg=Minutes*60;
datapoints=size(data,1);
bestdist=distance;
bestdisttemp=distance;      
Time=toc;

%while j<=2
while Time<seg
    Time=toc;
    if j==2 %segundo vecindario (Intercambio)
        for i=2:datapoints
            for k=i:datapoints
                Rtemp=Rbest;
                Rtemp(i)=Rbest(k);
                Rtemp(k)=Rbest(i);
                res=distancia(Dist,Rtemp);
                Time=toc;
                if res<bestdist
                    ver=verifi(data,Rtemp);
                    if ver == 1
                        Rbesttemp=Rtemp;
                        bestdisttemp=res;
                    end
                end
            end
        end
        if bestdisttemp == bestdist
            j=j+1;
            Time=toc;
        else
            j=1;
            bestdist=bestdisttemp;
            Rbest=Rbesttemp;
        end
    end
    if j==3 %tercer vecindario (insercion)
        for i=2:datapoints
            for k=i:datapoints
                Rtemp=Rbest;
                Rtemp(i)=Rbest(k);
                Rtemp(i+1:datapoints)=[Rbest(i:k-1) Rbest(k+1:datapoints)];
                res=distancia(Dist,Rtemp);
                Time=toc;
                if res<bestdist
                    ver=verifi(data,Rtemp);
                    if ver == 1
                        Rbesttemp=Rtemp;
                        bestdisttemp=res;
                    end
                end
            end
        end
        if bestdisttemp == bestdist
            j=j+1;
            Time=toc;
        else
            j=1;
            bestdist=bestdisttemp;
            Rbest=Rbesttemp;
        end
    end
    if j==1 %primer vecindario (2-opt)
        for i=2:datapoints
            for k=i:datapoints
                Rtemp=Rbest;
                Rtemp(i:k)=flip(Rtemp(i:k));
                res=distancia(Dist,Rtemp);
                Time=toc;
                if res<bestdist
                    ver=verifi(data,Rtemp);
                    if ver == 1
                        Rbesttemp=Rtemp;
                        bestdisttemp=res;
                    end
                end
            end
        end
        if bestdisttemp == bestdist
            Time=toc;
            break
        else
            j=1;
            bestdist=bestdisttemp;
            Rbest=Rbesttemp;
        end
    end
end
end


