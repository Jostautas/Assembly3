# INT 1 apdorojimo procedura, atpazistanti komanda PUSH r/m
 Žingsninio režimo pertraukimo (int 1) apdorojimo procedūra, atpažįstanti komandą PUSH r/m. Ši procedūra turi patikrinti, ar pertraukimas įvyko prieš prieš vykdant komandos PUSH pirmąjį variantą, jei taip, į ekraną išvesti perspėjimą, ir visą informaciją apie komandą: adresą, kodą, mnemoniką, operandus.
       Pvz.: Į ekraną išvedama informacija galėtų atrodyti taip: Zingsninio rezimo pertraukimas! 0000:0128  FF37  push [bx] ; bx= 0001, [bx]=1234, pirmas steko zodis 0202
