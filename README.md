# Encryptor App

Introduction:
===============
A simple encryption app to encrypt user data in android mobile phone. Hybrid encryption is used.
The data to be encrypted is split into three parts and encrypted with algorithms.

Algorithms used:
===============

Symmetric algorithms:
--------------------
     1.AES
     2.Salsa20
     3.Fernet

Asymmetric algorithm:
--------------------
RSA algorithm(for encryption of private keys)        

Feature:
===============
The order of encryption of the algorithms are randomized.

Application Guide:
==================
<!-----![](images/encryptor.png)--->
1.The <b>encryptor page</b> is used to encrypt user data<br>
<img src="images/encryptor.png" alt="drawing" width="280" height="400"/><br>
2.The <b>decryptor page</b> is to decrypt the encrypted data<br><br>
<img src="images/decryptor.png" alt="drawing" width="280" height="400"/><br>
3.The encrypted and decrypted data are stored in the phone storage in <b>MyEncFolder</b><br><br>
<img src="images/storage.png" alt="drawing" width="280" height="400"/>
<img src="images/myencfolder.png" alt="drawing" width="280" height="400"/><br>
4.The passwords can be changed in the <b>settings page</b><br><br>
<img src="images/settings.png" alt="drawing" width="280" height="400"/>