function Cbr = dva_dva_popravek(stolpci,matrika)
Cbr(:,1:2:stolpci-1) = matrika(:,:);
%polnenje stolpcev
Cbr(:,1:1:stolpci-1) = (Cbr(:,1:1:stolpci-1)+Cbr(:,1:1:stolpci-1))/2; 
%dodatek na robu
Cbr(:,stolpci) = Cbr(:,stolpci-1);
