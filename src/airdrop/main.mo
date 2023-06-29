import Set         "mo:map/Set";

import Result      "mo:base/Result";
import Principal   "mo:base/Principal";
import Time        "mo:base/Time";
import Nat64       "mo:base/Nat64";
import Int         "mo:base/Int";
import Blob        "mo:base/Blob";
import Buffer      "mo:base/Buffer";
import Debug       "mo:base/Debug";

import Token       "canister:token";

import ICRC1       "mo:icrc1/ICRC1";

shared({caller = controller}) actor class Airdrop(
  amount_e8s_per_user: Nat,
  allow_self_airdrop: Bool
) = this {

  public type AuthorizationError = {
    #NotAuthorized;
  };

  public type AirdropError = ICRC1.TransferError or AuthorizationError or {
    #AlreadySupplied;
    #AirdropOver;
  };

  public type AirdropResult = Result.Result<ICRC1.TxIndex, AirdropError>;

  stable var _controller          = controller;
  stable var _amount_e8s_per_user = amount_e8s_per_user;
  stable var _allow_self_airdrop  = allow_self_airdrop;
  stable let _airdropped_users    = Set.new<Principal>(Set.phash);

  public query func getController() : async Principal {
    _controller;
  };

  public shared({caller}) func setController(new_controller: Principal) : async Result.Result<(), AuthorizationError> {
    if (caller != _controller) {
      return #err(#NotAuthorized);
    };
    _controller := new_controller;
    #ok;
  };

  public query func getAmountPerUser() : async Nat {
    _amount_e8s_per_user;
  };

  public shared({caller}) func setAmountPerUser(new_amount: Nat) : async Result.Result<(), AuthorizationError> {
    if (caller != _controller) {
      return #err(#NotAuthorized);
    };
    _amount_e8s_per_user := new_amount;
    #ok;
  };

  public query func isSelfAirdropAllowed() : async Bool {
    _allow_self_airdrop;
  };

  public shared({caller}) func allowSelfAirdrop(new_allow: Bool) : async Result.Result<(), AuthorizationError> {
    if (caller != _controller) {
      return #err(#NotAuthorized);
    };
    _allow_self_airdrop := new_allow;
    #ok;
  };

  public shared func getRemainingSupply() : async ICRC1.Balance {
    await Token.icrc1_balance_of({ owner = Principal.fromActor(this); subaccount = null; });
  };

  public shared({caller}) func airdropSelf() : async AirdropResult {
    if (not(_allow_self_airdrop)){
      return #err(#NotAuthorized);
    };
    await* airdrop(caller);
  };

  public shared({caller}) func airdropUser(user: Principal) : async AirdropResult {
    if (caller != _controller) {
      return #err(#NotAuthorized);
    };
    await* airdrop(user);
  };

  func airdrop(principal: Principal) : async* AirdropResult {

    if (Set.has(_airdropped_users, Set.phash, principal)) {
      return #err(#AlreadySupplied);
    };

    let mint_result = toBaseResult(await Token.mint({
      to = {
        owner = Principal.fromActor(this);
        subaccount = ?toSubaccount(principal);
      };
      amount = _amount_e8s_per_user;
      memo = null;
      created_at_time = ?Nat64.fromNat(Int.abs(Time.now()));
    }));

    Result.iterate(mint_result, func(tx_index: Token.TxIndex){
      ignore Set.put(_airdropped_users, Set.phash, principal);
    });

    mint_result;
  };

  // @todo: this should be part of another module
  // Subaccount shall be a blob of 32 bytes
  func toSubaccount(principal: Principal) : Blob {
    let blob_principal = Blob.toArray(Principal.toBlob(principal));
    // According to IC interface spec: "As far as most uses of the IC are concerned they are
    // opaque binary blobs with a length between 0 and 29 bytes"
    if (blob_principal.size() > 32) {
      Debug.trap("Cannot convert principal to subaccount: principal length is greater than 32 bytes");
    };
    let buffer = Buffer.Buffer<Nat8>(32);
    buffer.append(Buffer.fromArray(blob_principal));
    // Add padding until 32 bytes
    while(buffer.size() < 32) {
      buffer.add(0);
    };
    // Return the buffer as a blob
    Blob.fromArray(Buffer.toArray(buffer));
  };

  type TokenResult<Ok, Err> = {
    #Ok: Ok;
    #Err: Err;
  };

  // @todo: this should be part of another module
  func toBaseResult<Ok, Err>(icrc1_result: TokenResult<Ok, Err>) : Result.Result<Ok, Err> {
    switch(icrc1_result){
      case(#Ok(ok)) {
        #ok(ok);
      };
      case(#Err(err)) {
        #err(err);
      };
    };
  };
  
};