function [R,distance,Time,Wbest] = PDTSP_GARSP3(data,Q,Dist,Nexp,Nrand)
%data es la matriz de datos
%Q s la capasidad del vehiculo en numeros negativos
%Dist es la matriz de distancias calculadas apartir de los datos, pero se
%toma como parametro
%Nrand es el numero de mejores opciones que se quiere encontrar para
%escoger una aleatoria entre estas

tic
Nnodes = size(data,1); %Cantidad de Nodos
R=zeros(1,Nnodes+1); %Vector respuesta
Rtemp=zeros(1,Nnodes);
M=500000; %penalizacion por cada W
Rtemp(1,1)=1;
R(1,1)=1;
BestScenario=inf;%valor inicial alto
%recorre la cantidad de nodos para asi asignar un camino

newdist=zeros(Nnodes,Nnodes*2);
for j=1:Nnodes
    newdist(:,j*2-1)=Dist(:,j);
    newdist(:,j*2)=data(:,1);
    newdist(:,j*2-1:j*2)=sortrows(newdist(:,j*2-1:j*2));
end

for p=1:Nexp
    visitedNodes=ones(Nnodes,1);% Vector que verifica que ya se visito o no un nodo
    visitedNodes(1,1)=0;
    actualQ=data(1,4);
    VisitedMatrix=zeros(Nnodes,Nnodes); %Matriz que marca desde que nodo se visito que nodo
    W=0; %Carga extra necesarias para cumplir con el recorrido
    ActualNode = 1; %Nodo inicial
    for i=2:Nnodes
        B=[visitedNodes>0 (actualQ + data(:,4))>=(Q+W) (actualQ + data(:,4))<=0];
        if sum(B(:,1).*B(:,2).*B(:,3)) == 0
            W=W+max(((1-B(:,3))*-100)+((1-B(:,1))*-100)+((1-B(:,2)).*data(:,4)))-Q+actualQ;
        end
        
        C=[visitedNodes>0 (actualQ + data(:,4))>=(Q+W) (actualQ + data(:,4))<=0];
        P=C(:,1).*C(:,2).*C(:,3);
        PM=nonzeros(P(newdist(:,ActualNode*2)).*newdist(:,ActualNode*2))';
        
        if size(PM,2)>Nrand
            PM=PM(:,1:Nrand);
        end
        
        bestNode = PM(1,randi([1, size(PM,2)]));       
        
        actualQ = actualQ+data(bestNode,4);
        ActualNode=bestNode;
        visitedNodes(ActualNode,1)=0;
        VisitedMatrix(bestNode,Rtemp(i-1))=1;
        Rtemp(1,i)=bestNode;
    end
    
    if sum(sum(Dist.*VisitedMatrix))+Dist(bestNode,1)+(-W)*M < BestScenario
        
        R(1,1:size(Rtemp,2))=Rtemp;
        BestScenario = sum(sum(Dist.*VisitedMatrix))+Dist(bestNode,1)+(-W)*M;
        R(1,Nnodes+1)=1;
        distance=sum(sum(ceil(Dist).*VisitedMatrix))+ceil(Dist(bestNode,1));
        Wbest=-W;
        
    end
end

Time=toc;

end