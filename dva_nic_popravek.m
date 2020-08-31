
function Cbr = dva_nic_popravek(vrstice,stolpci,matrika)
Cbr = zeros(vrstice, stolpci);
Cbr(1:2:vrstice-1,1:2:stolpci-1) = matrika(:,:);
%polnenje stolpcev in vrstic
Cbr(1:2:vrstice-1,2:2:stolpci-2) = (Cbr(1:2:vrstice-1,1:2:stolpci-3)+Cbr(1:2:vrstice-1,3:2:stolpci-1) )/2;  
Cbr(2:2:vrstice-2,1:1:stolpci-1) = (Cbr(1:2:vrstice-3,1:1:stolpci-1)+Cbr(3:2:vrstice-1,1:1:stolpci-1) )/2;
%polnenje roba
Cbr(1:1:vrstice-1,stolpci) = Cbr(1:1:vrstice-1,stolpci-1);
Cbr(vrstice,1:1:end) = Cbr(vrstice-1,1:1:end);