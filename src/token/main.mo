import Principal          "mo:base/Principal";
import Int                "mo:base/Int";
import Nat8               "mo:base/Nat8";
import Option             "mo:base/Option";

import ExperimentalCycles "mo:base/ExperimentalCycles";

import ICRC1              "mo:icrc1/ICRC1";

// @todo: UNCOMMENT HERE:
//actor Token {
shared({ caller = _owner }) actor class Token(token_args : ICRC1.TokenInitArgs) {

  type Account                 = ICRC1.Account;
  type Subaccount              = ICRC1.Subaccount;
  type Transaction             = ICRC1.Transaction;
  type Balance                 = ICRC1.Balance;
  type TransferArgs            = ICRC1.TransferArgs;
  type Mint                    = ICRC1.Mint;
  type BurnArgs                = ICRC1.BurnArgs;
  type SupportedStandard       = ICRC1.SupportedStandard;
  type InitArgs                = ICRC1.InitArgs;
  type MetaDatum               = ICRC1.MetaDatum;
  type TxIndex                 = ICRC1.TxIndex;
  type GetTransactionsRequest  = ICRC1.GetTransactionsRequest;
  type GetTransactionsResponse = ICRC1.GetTransactionsResponse;
  type TransferResult          = ICRC1.TransferResult;

  let DECIMALS : Nat = 8;
  let TOKEN_UNIT : Nat = 10 ** DECIMALS;
  let TOKEN_SUPPLY : Nat = 1_000_000_000 * TOKEN_UNIT;
  let FEE : Nat = 10_000;

  // @todo: UNCOMMENT HERE:

//  let token_args : ICRC1.TokenInitArgs = {
//    name = "Name";
//    symbol = "COIN";
//    decimals = Nat8.fromNat(DECIMALS);
//    fee = FEE;
//    max_supply = TOKEN_SUPPLY;
//    initial_balances = [];
//    min_burn_amount = FEE;
//    minting_account = ?{ owner = Principal.fromText("bkyz2-fmaaa-aaaaa-qaaaq-cai"); subaccount = null; };
//    advanced_settings = null;
//  };

  let icrc1_args : ICRC1.InitArgs = {
    token_args with minting_account = Option.get(
      token_args.minting_account,
      {
        owner = Principal.fromText("bkyz2-fmaaa-aaaaa-qaaaq-cai");
        subaccount = null;
      },
    );
  };

  stable let token = ICRC1.init(icrc1_args);

  /// Functions for the ICRC1 token standard
  public shared query func icrc1_name() : async Text {
    ICRC1.name(token);
  };

  public shared query func icrc1_symbol() : async Text {
    ICRC1.symbol(token);
  };

  public shared query func icrc1_decimals() : async Nat8 {
    ICRC1.decimals(token);
  };

  public shared query func icrc1_fee() : async Balance {
    ICRC1.fee(token);
  };

  public shared query func icrc1_metadata() : async [MetaDatum] {
    ICRC1.metadata(token);
  };

  public shared query func icrc1_total_supply() : async Balance {
    ICRC1.total_supply(token);
  };

  public shared query func icrc1_minting_account() : async ?Account {
    ?ICRC1.minting_account(token);
  };

  public shared query func icrc1_balance_of(args : Account) : async Balance {
    ICRC1.balance_of(token, args);
  };

  public shared query func icrc1_supported_standards() : async [SupportedStandard] {
    ICRC1.supported_standards(token);
  };

  public shared ({ caller }) func icrc1_transfer(args : TransferArgs) : async TransferResult {
    await* ICRC1.transfer(token, args, caller);
  };

  public shared ({ caller }) func mint(args : Mint) : async TransferResult {
    await* ICRC1.mint(token, args, caller);
  };

  public shared ({ caller }) func burn(args : BurnArgs) : async TransferResult {
    await* ICRC1.burn(token, args, caller);
  };

  // Functions from the rosetta icrc1 ledger
  public shared query func get_transactions(req : GetTransactionsRequest) : async GetTransactionsResponse {
    ICRC1.get_transactions(token, req);
  };

  // Additional functions not included in the ICRC1 standard
  public shared func get_transaction(i : TxIndex) : async ?Transaction {
    await* ICRC1.get_transaction(token, i);
  };

  // Deposit cycles into this archive canister.
  public shared func deposit_cycles() : async () {
    let amount = ExperimentalCycles.available();
    let accepted = ExperimentalCycles.accept(amount);
    assert (accepted == amount);
  };

  public query func get_cycles_balance() : async Nat {
    ExperimentalCycles.balance();
  };

};
