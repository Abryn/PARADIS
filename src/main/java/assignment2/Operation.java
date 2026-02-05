// Albin Phillips

package assignment2;

class Operation implements Runnable {
	private final int ACCOUNT_ID;
	private final int AMOUNT;
	private final Account account;
	
	Operation(Bank bank, int accountId, int amount) {
		ACCOUNT_ID = accountId;
		AMOUNT = amount;
		account = bank.getAccount(ACCOUNT_ID);
	}

	// Method for updating balance without locking, must be handled by the caller by using getAccount and locking
	// that way, this is to avoid double locking in Transaction.java even though the lock is reentrant
	protected void updateBalance() {
		int balance = account.getBalance();
		balance = balance + AMOUNT;
		account.setBalance(balance);
	}

	// Method used in Transaction.java to get the account lock and sort by account ID
	// Worse encapsulation but simpler and works if handled correctly (could use a map with ID and lock in Transaction)
	protected Account getAccount() {
		return account;
	}
	
	public void run() {
		// Only used for single operations
		// Get the lock to ensure atomic account balance update
		account.getLock().lock();
		try {
			updateBalance();
		} finally {
			account.getLock().unlock();
		}
	}
}	
