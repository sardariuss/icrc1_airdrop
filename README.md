# icrc1_airdrop

When using the actor class instead of actor for the Token canister, the compilation of the Airdrop canister fails on src/airdrop/main.mo:100.23-100.46 :
subaccount = ?toSubaccount(principal);

with the error : type error [M0096], expression of type
  Blob
cannot produce expected type
  [Nat8]

This error does not happen if the actor is declared without the class.
