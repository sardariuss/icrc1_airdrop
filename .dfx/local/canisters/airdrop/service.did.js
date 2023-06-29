export const idlFactory = ({ IDL }) => {
  const TxIndex__1 = IDL.Nat;
  const Balance__1 = IDL.Nat;
  const TxIndex = IDL.Nat;
  const Timestamp = IDL.Nat64;
  const AirdropError = IDL.Variant({
    'GenericError' : IDL.Record({
      'message' : IDL.Text,
      'error_code' : IDL.Nat,
    }),
    'TemporarilyUnavailable' : IDL.Null,
    'BadBurn' : IDL.Record({ 'min_burn_amount' : Balance__1 }),
    'Duplicate' : IDL.Record({ 'duplicate_of' : TxIndex }),
    'AirdropOver' : IDL.Null,
    'NotAuthorized' : IDL.Null,
    'BadFee' : IDL.Record({ 'expected_fee' : Balance__1 }),
    'CreatedInFuture' : IDL.Record({ 'ledger_time' : Timestamp }),
    'AlreadySupplied' : IDL.Null,
    'TooOld' : IDL.Null,
    'InsufficientFunds' : IDL.Record({ 'balance' : Balance__1 }),
  });
  const AirdropResult = IDL.Variant({
    'ok' : TxIndex__1,
    'err' : AirdropError,
  });
  const AuthorizationError = IDL.Variant({ 'NotAuthorized' : IDL.Null });
  const Result = IDL.Variant({ 'ok' : IDL.Null, 'err' : AuthorizationError });
  const Balance = IDL.Nat;
  const Airdrop = IDL.Service({
    'airdropSelf' : IDL.Func([], [AirdropResult], []),
    'airdropUser' : IDL.Func([IDL.Principal], [AirdropResult], []),
    'allowSelfAirdrop' : IDL.Func([IDL.Bool], [Result], []),
    'getAmountPerUser' : IDL.Func([], [IDL.Nat], ['query']),
    'getController' : IDL.Func([], [IDL.Principal], ['query']),
    'getRemainingSupply' : IDL.Func([], [Balance], []),
    'isSelfAirdropAllowed' : IDL.Func([], [IDL.Bool], ['query']),
    'setAmountPerUser' : IDL.Func([IDL.Nat], [Result], []),
    'setController' : IDL.Func([IDL.Principal], [Result], []),
  });
  return Airdrop;
};
export const init = ({ IDL }) => { return []; };
