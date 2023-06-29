import type { Principal } from '@dfinity/principal';
import type { ActorMethod } from '@dfinity/agent';

export interface Airdrop {
  'airdropSelf' : ActorMethod<[], AirdropResult>,
  'airdropUser' : ActorMethod<[Principal], AirdropResult>,
  'allowSelfAirdrop' : ActorMethod<[boolean], Result>,
  'getAmountPerUser' : ActorMethod<[], bigint>,
  'getController' : ActorMethod<[], Principal>,
  'getRemainingSupply' : ActorMethod<[], Balance>,
  'isSelfAirdropAllowed' : ActorMethod<[], boolean>,
  'setAmountPerUser' : ActorMethod<[bigint], Result>,
  'setController' : ActorMethod<[Principal], Result>,
}
export type AirdropError = {
    'GenericError' : { 'message' : string, 'error_code' : bigint }
  } |
  { 'TemporarilyUnavailable' : null } |
  { 'BadBurn' : { 'min_burn_amount' : Balance__1 } } |
  { 'Duplicate' : { 'duplicate_of' : TxIndex } } |
  { 'AirdropOver' : null } |
  { 'NotAuthorized' : null } |
  { 'BadFee' : { 'expected_fee' : Balance__1 } } |
  { 'CreatedInFuture' : { 'ledger_time' : Timestamp } } |
  { 'AlreadySupplied' : null } |
  { 'TooOld' : null } |
  { 'InsufficientFunds' : { 'balance' : Balance__1 } };
export type AirdropResult = { 'ok' : TxIndex__1 } |
  { 'err' : AirdropError };
export type AuthorizationError = { 'NotAuthorized' : null };
export type Balance = bigint;
export type Balance__1 = bigint;
export type Result = { 'ok' : null } |
  { 'err' : AuthorizationError };
export type Timestamp = bigint;
export type TxIndex = bigint;
export type TxIndex__1 = bigint;
export interface _SERVICE extends Airdrop {}
