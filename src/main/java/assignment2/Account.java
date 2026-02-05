// Albin Phillips

package assignment2;

import java.util.concurrent.locks.ReentrantLock;

class Account {
	// Instance variables.
	private final int ID;
	private int balance;

	// Lock handled by other classes (Transaction and Operation)
	private final ReentrantLock lock = new ReentrantLock();
	
	// Constructor.
	Account(int id, int balance) {
		ID = id;
		this.balance = balance;
	}
	
	// Instance methods.
	
	int getId() {
		return ID;
	}
	
	int getBalance() {
		return balance;
	}
	
	void setBalance(int balance) {
		this.balance = balance;
	}

	// Exposed lock handled by caller, must get the lock before balance operations
	protected ReentrantLock getLock() {
		return lock;
	}
}
