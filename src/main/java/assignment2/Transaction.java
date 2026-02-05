// Albin Phillips

package assignment2;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashSet;
import java.util.List;

class Transaction implements Runnable {
	private final List<Operation> operations = new ArrayList<>();
	private boolean closed = false;
	
	void add(Operation operation) {
		if (closed) return;
		operations.add(operation);
	}
	
	void close() {
		closed = true;
	}
	
	public void run() {
		if (!closed) return;

		// Acquire all necessary locks
		HashSet<Account> accountSet = new HashSet<>();
		for (Operation operation : operations) {
			accountSet.add(operation.getAccount());
		}

		// Sort the set to allow locking in order to avoid deadlock
		ArrayList<Account> accounts = new ArrayList<>(accountSet);
		accounts.sort(Comparator.comparingInt(Account::getId));

		// Lock all locks before any operation (can now use updateBalance() instead of run() in Operation.java)
		for (Account acc : accounts) {
			acc.getLock().lock();
		}

		try {
			// Execute the operations.
			for (Operation operation : operations) {
				// To avoid double locking the run() method is not used instead updateBalance which
				// doesnt use any lock logic, but it must be handled correctly by acquiring locks beforehand
				operation.updateBalance();
			}
		} finally {
			// Release all locks in reverse
			for (int i = accounts.size() - 1; i >= 0; i--) {
				accounts.get(i).getLock().unlock();
			}
		}
	}
}	
