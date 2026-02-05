// Albin Phillips

package assignment2;

import java.util.List;
import java.util.ArrayList;
import java.util.concurrent.locks.ReentrantReadWriteLock;

class Bank {
	// Instance variables.
	private final List<Account> accounts = new ArrayList<>();

	// ReadWriteLock for multiple readers or one exclusive writer
	// Readers block writers and writers block both readers and other writers
	private final ReentrantReadWriteLock lock = new ReentrantReadWriteLock();
	
	// Instance methods.
	// Write lock ensures that only one thread can update the accounts list at a time
	int newAccount(int balance) {
		lock.writeLock().lock();
		try {
			int accountId = accounts.size();
			accounts.add(new Account(accountId, balance));
			return accountId;
		} finally {
			lock.writeLock().unlock();
		}
	}

	// Read lock allows multiple threads to read accounts concurrently while the write lock is free
	Account getAccount(int accountId) {
		lock.readLock().lock();
		try {
			return accounts.get(accountId);
		} finally {
			lock.readLock().unlock();
		}
	}
}
