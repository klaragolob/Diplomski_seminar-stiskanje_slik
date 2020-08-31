%JPEG ALGORITEM ZA STISKANJE BARVNIH SLIK

clc;
clear all;

%--------------------------------------------------------------------------
%Vpraša za naslov slike
ime_slike = input('Vnesi ime slike: ');
I = imread(ime_slike);
%Vpraša za stopnjo kompresije
kvaliteta = input('Vnesi stopnjo stiskanja (med 0 in 100): ');
if (kvaliteta > 100) || (kvaliteta < 0)
    kvaliteta = input('Stonja stiskanja ni v redu. Vmesi število med 0 in 100: ');
end
%vpraša za format stiskanja:
format = input('Vnesi željeni format. Za 4:4:4 število 1, za 4:2:2 število 2 in za 4:2:0 število 3: ');
if ((format == 1) || (format == 2) || (format == 3))
else
    format = input("Format ni v redu. Vnesi še enkrat za 4:4:4 število 1, za 4:2:2 število 2 in za 4:2:0 število 3: ");
end
%--------------------------------------------------------------------------
N = 8;   %velikost bloka
%Odstrani piksle na robu, da se lahko matriko razdeli na 8x8 bloke
[vrstice, stolpci,k] = size(I);
v = mod(vrstice,N);
novo_st_vrstic = vrstice-v;
s = mod(stolpci,N);
novo_st_stolpcev = stolpci-s;
I = imresize(I,[novo_st_vrstic, novo_st_stolpcev]) ;
%--------------------------------------------------------------------------
%originalna slika
figure(1);
imshow(I);
title('Originalna slika')
%--------------------------------------------------------------------------
[vrstice, stolpci,k] = size(I);
I = double(I);     
R = I(:, :, 1);
G = I(:, :, 2);
B = I(:, :, 3);
% Pretvorba barvnega sistema RBG -> YCbCr
transformacija = [0.299000 0.587000 0.114000 ; -0.168736 -0.331264 0.500002 ; 0.500000 -0.418688 -0.081312];
Y =  transformacija(1,1) * R + transformacija(1,2) * G + transformacija(1,3) * B;
Cb = transformacija(2,1) * R + transformacija(2,2) * G + transformacija(2,3) * B + 128;
Cr = transformacija(3,1) * R + transformacija(3,2) * G + transformacija(3,3) * B + 128;

%--------------------------------------------------------------------------
%PRVI KORAK KOMPRESIJE NA Cb in Cr MATRIKAH
if format == 3
    Cbr(:,:) = Cb(1:2:end,1:2:end);  
    Crr(:,:) = Cr(1:2:end,1:2:end);   
elseif format == 1
    Cbr = Cb;
    Crr = Cr;
else
    Cbr(:,:) = Cb(:,1:2:end);
    Crr(:,:) = Cr(:,1:2:end);
end
%popravi dimenzijo matrik, da se jo lahko razdeli na 8x8 bloke
[vrsticeCC, stolpciCC] = size(Cbr);
vC = mod(vrsticeCC,N);
vrsticeC = vrsticeCC-vC;
sC = mod(stolpciCC,N);
stolpciC = stolpciCC-sC;

% DISKRETNA KOSINUSNA TRANSFORMACIJA
dct = dctmtx(N);
for i=1:N:vrstice
    for j=1:N:stolpci
        blokY=Y(i:i+N-1,j:j+N-1);
        transformacijaformiran_blokY=dct*blokY*dct';
        transformacijaformirana_matrikaY(i:i+N-1,j:j+N-1)=transformacijaformiran_blokY;
    end
end
for i=1:N:vrsticeC
    for j=1:N:stolpciC
        blok=Cbr(i:i+N-1,j:j+N-1);
        transformacijaformiran_blokCb=dct*blok*dct';
        transformacijaformirana_matrikaCb(i:i+N-1,j:j+N-1)=transformacijaformiran_blokCb;
    end
end
for i=1:N:vrsticeC
    for j=1:N:stolpciC
        blok=Crr(i:i+N-1,j:j+N-1);
        transformacijaformiran_blokCr=dct*blok*dct';
        transformacijaformirana_matrikaCr(i:i+N-1,j:j+N-1)=transformacijaformiran_blokCr;
    end
end

%KVANTIZACIJA
%Standardna kvantizacijska matrika
Q50 = [16 11 10 16 24 40 51 61;     
            12 12 14 19 26 58 60 55;
            14 13 16 24 40 57 69 56;
            14 17 22 29 51 87 80 62; 
            18 22 37 56 68 109 103 77;
            24 35 55 64 81 104 113 92;
            49 64 78 87 103 121 120 101;
            72 92 95 98 112 100 103 99];
%izračun kvantizacijske matrike        
if kvaliteta > 50
    Q = round(Q50.*(ones(8)*((100-kvaliteta)/50)));
    Q = uint8(Q);
elseif kvaliteta < 50
    Q = round(Q50.*(ones(8)*(50/kvaliteta)));
    Q = uint8(Q);
elseif kvaliteta == 50
    Q = Q50;
end
Q = double(Q);
    
for i=1:N:vrstice 
    for j=1:N:stolpci
        transformacijaformiran_blokY = transformacijaformirana_matrikaY(i:i+N-1,j:j+N-1);
        kvantiziran_blokY=round(transformacijaformiran_blokY./Q);
        kvantizirana_matrikaY(i:i+N-1,j:j+N-1)=kvantiziran_blokY;
    end
end
for i=1:N:vrsticeC 
    for j=1:N:stolpciC
        transformacijaformiran_blokCb = transformacijaformirana_matrikaCb(i:i+N-1,j:j+N-1);
        kvantiziran_blokCb=round(transformacijaformiran_blokCb./Q);
        kvantizirana_matrikaCb(i:i+N-1,j:j+N-1)=kvantiziran_blokCb;
    end
end
for i=1:N:vrsticeC 
    for j=1:N:stolpciC
        transformacijaformiran_blokCr = transformacijaformirana_matrikaCr(i:i+N-1,j:j+N-1);
        kvantiziran_blokCr=round(transformacijaformiran_blokCr./Q);
        kvantizirana_matrikaCr(i:i+N-1,j:j+N-1)=kvantiziran_blokCr;
    end
end


%--------------------------------------------------------------------------
%RAZŠIRJANJE MATRIKE

%DEKVANTIZACIJA
for i=1:N:vrstice
    for j=1:N:stolpci
        kvantiziran_blokY = kvantizirana_matrikaY(i:i+N-1,j:j+N-1);
        dekvantiziran_blokY = kvantiziran_blokY.*Q;
        dekvantizirana_matrikaY(i:i+N-1,j:j+N-1) = dekvantiziran_blokY;
    end
end
for i=1:N:vrsticeC
    for j=1:N:stolpciC
        kvantiziran_blokCb = kvantizirana_matrikaCb(i:i+N-1,j:j+N-1);
        dekvantiziran_blokCb = kvantiziran_blokCb.*Q;
        dekvantizirana_matrikaCb(i:i+N-1,j:j+N-1) = dekvantiziran_blokCb;
    end
end
for i=1:N:vrsticeC
    for j=1:N:stolpciC
        kvantiziran_blokCr = kvantizirana_matrikaCr(i:i+N-1,j:j+N-1);
        dekvantiziran_blokCr = kvantiziran_blokCr.*Q;
        dekvantizirana_matrikaCr(i:i+N-1,j:j+N-1) = dekvantiziran_blokCr;
    end
end

%INVERZNA DISKRETNA KOSINUSNA TRANSFORMACIJA
for i=1:N:vrstice
    for j=1:N:stolpci
        dekvantiziran_blokY = dekvantizirana_matrikaY(i:i+N-1,j:j+N-1);
        razsirjen_blokY=dct'*dekvantiziran_blokY*dct;
        razsirjena_matrikaY(i:i+N-1,j:j+N-1)=razsirjen_blokY;
    end
end
for i=1:N:vrsticeC
    for j=1:N:stolpciC
        dekvantiziran_blokCb = dekvantizirana_matrikaCb(i:i+N-1,j:j+N-1);
        razsirjen_blokCb=dct'*dekvantiziran_blokCb*dct;
        razsirjena_matrikaCb(i:i+N-1,j:j+N-1)=razsirjen_blokCb;
    end
end
for i=1:N:vrsticeC
    for j=1:N:stolpciC
        dekvantiziran_blokCr = dekvantizirana_matrikaCr(i:i+N-1,j:j+N-1);
        razsirjen_blokCr=dct'*dekvantiziran_blokCr*dct;
        razsirjena_matrikaCr(i:i+N-1,j:j+N-1)=razsirjen_blokCr;
    end
end

%RAZŠIRJANJE Cb IN Cr MATRIK
razsirjena_matrikaCbr = zeros(vrsticeCC, stolpciCC);
razsirjena_matrikaCbr(1:vrsticeC, 1:stolpciC) = razsirjena_matrikaCb;
razsirjena_matrikaCrr = zeros(vrsticeCC, stolpciCC);
razsirjena_matrikaCrr(1:vrsticeC, 1:stolpciC) = razsirjena_matrikaCr;
if format == 3
    Cbr = dva_nic_popravek(vrstice,stolpci,razsirjena_matrikaCbr);
    Crr = dva_nic_popravek(vrstice,stolpci,razsirjena_matrikaCrr);
elseif format == 2
    Cbr = dva_dva_popravek(stolpci,razsirjena_matrikaCbr);
    Crr = dva_dva_popravek(stolpci,razsirjena_matrikaCrr);
end

%--------------------------------------------------------------------------
YY = razsirjena_matrikaY;
%Pretvorba barvnega sistema YCbCr -> RGB
itransformacija = inv(transformacija);
R = itransformacija(1,1)* YY + itransformacija(1,2)* (Cb-128) + itransformacija(1,3)* (Cr-128) ;
G= itransformacija(2,1)* YY + itransformacija(2,2)* (Cb-128) + itransformacija(2,3)* (Cr-128) ;
B = itransformacija(3,1)* YY + itransformacija(3,2)* (Cb-128) + itransformacija(3,3)* (Cr-128) ;
I(:,:,1) = R;
I(:,:,2) = G;
I(:,:,3) = B;
%--------------------------------------------------------------------------
%RAZŠIRJENA MATRIKA
figure(2)
stisnjena_slika =uint8(I);
title('Stisnjena slika')
imshow(stisnjena_slika)



