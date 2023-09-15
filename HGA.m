function [RbestAll,bestdistAll,Time,P]=HGA(prob,miternum,maxlim,initpop,Minutes,data,Q,Dist,Nexp,Nrand)

tic %Inicia a contar el tiempo
datapoints=size(data,1);
R=zeros(initpop,datapoints+1);
distance=zeros(initpop,1);
W=ones(initpop,1);

%crea las soluciones iniciales, no necesitan ser factibles
for n=1:initpop
    [R(n,:),distance(n,:),~,W(n,:)]=PDTSP_GARSP3(data,Q,Dist,Nexp,Nrand);
end


seg=Minutes*60;
bestinitsol = inf;

k=initpop/2;
Winner=zeros(k,datapoints+1); %Guarda el orden de nodos de los ganadores
Wdist=zeros(k,1); %guarda las distancias de los ganadores
WW=ones(k,1); %guarda los pesos de los ganadores
Sons=zeros(k-1,datapoints+1);
Sdist=ones(k,1); %guarda las distancias de los hijos
SW=ones(k,1); %guarda los pesos de los hijos

Time=toc;
while Time<seg %cambiar por un While
    for n=1:initpop
        H=verifi(data,R(n,:));
        if bestinitsol > distance(n,:) && H==0
            bestdistAll=distance(n,:);
            RbestAll=R(n,:);
            bestinitsol = distance(n,:);
            P=H;
        end
    end
    r = randi([2 datapoints],1,k);
    rm = rand(1,initpop);
    %Torneo, elimina la mitad de la poblacion
    for j=1:k
        best=min(distance(j+(j-1)),distance(j*2));
        if distance(j+(j-1))==best
            Winner(j,:)=R(j+(j-1),:);
            Wdist(j,:)=best;
            WW(j,:)=W(j+(j-1),:);
        else
            Winner(j,:)=R(j*2,:);
            Wdist(j,:)=best;
            WW(j,:)=W(j*2,:);
        end
    end
    %hijos, crea soluciones para completar la poblacion
    %cruce por un punto
    
    for l=1:(k-1)
        Sons(l,1:r(l))= Winner(l,1:r(l));
        Sons(l,(r(l)+1):datapoints)=setdiff(Winner(l+1,:),Winner(l,1:r(l)),'stable');
        Sons(l,datapoints+1)=1;
        Sdist(l,:)=distancia(Dist,Sons(l,:));
        SW(l,:)=verifi(data,Sons(l,:));
    end
    %crea el ultimo hijo entre el primero y el ultimo
    Sons(k,1:r(k))= Winner(k,1:r(k));
    Sons(k,(r(k)+1):datapoints)=setdiff(Winner(1,:),Winner(k,1:r(k)),'stable');
    Sons(k,datapoints+1)=1;
    Sdist(k,:)=distancia(Dist,Sons(k,:));
    SW(k,:)=verifi(data,Sons(k,:));
    
    R=[Winner;Sons];
    distance=[Wdist;Sdist];
    W=[WW;SW];
    b=1;
    
    %Mutacion con VND y probabilidad parametrizada
    Time=toc;
    for m=11:initpop
        bestdisttemp=distance(m,:);
        if rm(1,m)<=prob
            j=1;
            b=1;
            while b<=miternum
                if j==1 %2-opt
                    for n=2:datapoints-1
                        techo=min(n+maxlim,datapoints-1);
                        for t=n:techo
                            Rtemp=R(m,:);
                            Rtemp(n:t)=flip(Rtemp(n:t));
                            ver=verifi(data,Rtemp);
                            Time=toc; % para parar
                            if ver == 0
                                res=distancia(Dist,Rtemp);
                                if res<bestdisttemp
                                    Rbesttemp=Rtemp;
                                    bestdisttemp=res;
                                end
                            end
                        end
                    end
                    if bestdisttemp == distance(m,:)
                        b=b+1;
                        j=j+1;
                        Time=toc;
                    else
                        b=b+1;
                        distance(m,:)=bestdisttemp;
                        R(m,:)=Rbesttemp;
                    end
                    
                elseif j==2 %segundo vecindario (Intercambio)
                    for o=2:datapoints
                        for t=o:datapoints
                            Rtemp=R(m,:);
                            Rtemp(t)=R(m,o);
                            Rtemp(o)=R(m,t);
                            ver=verifi(data,Rtemp);
                            Time=toc;
                            if ver == 0
                                res=distancia(Dist,Rtemp);
                                if res<bestdisttemp
                                    Rbesttemp=Rtemp;
                                    bestdisttemp=res;
                                end
                            end
                        end
                    end
                    if bestdisttemp == distance(m,:)
                        Time=toc;
                        break
                    else
                        b=b+1;
                        j=1;
                        distance(m,:)=bestdisttemp;
                        R(m,:)=Rbesttemp;
                    end
                end
            end
        end
    end
end
end

    