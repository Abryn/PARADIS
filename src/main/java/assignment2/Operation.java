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
	
	int getAccountId() {
		return ACCOUNT_ID;
	}
	
	public void run() {
		// Get the lock to ensure atomic account balance operations
		account.getLock().lock();
		try {
			int balance = account.getBalance();
			balance = balance + AMOUNT;
			account.setBalance(balance);
		} finally {
			account.getLock().unlock();
		}
	}
}	
