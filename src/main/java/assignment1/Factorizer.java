// Albin Phillips

package assignment1;
import java.math.BigInteger;
import java.util.Scanner;

public class Factorizer implements Runnable {
    private static BigInteger product;
    private static BigInteger max;
    private static boolean found = false;
    private final BigInteger min;
    private final BigInteger step;
    public static BigInteger factor1;
    public static BigInteger factor2;

    public Factorizer(BigInteger product, BigInteger min, BigInteger max, BigInteger step) {
        Factorizer.product = product;
        Factorizer.max = max;
        this.min = min;
        this.step = step;
    }

    @Override
    public void run() {
        BigInteger number = min;
        int counter = 0;
        while (number.compareTo(max) <= 0) {
            if (counter++ % 1000 == 0 && isFound()) {
                return;
            }
            if (product.remainder(number).compareTo(BigInteger.ZERO) == 0) {
                synchronized (Factorizer.class) {
                    if (!found) {
                        factor1 = number;
                        factor2 = product.divide(factor1);
                        found = true;
                    }
                }
                return;
            }
            number = number.add(step);
        }
    }

    private static synchronized boolean isFound() {
        return found;
    }

    private static boolean isOdd(BigInteger bi) {
        return bi.testBit(0);
    }

    public static void main(String[] args) {
        Scanner scanner = new Scanner(System.in);
        System.out.print("Enter product: ");
        product = new BigInteger(scanner.next());
        BigInteger min;
        max = product.sqrt();
        BigInteger step;
        BigInteger inc = BigInteger.valueOf(1);

        System.out.print("Enter number of threads to use: ");
        int numThreads = scanner.nextInt();

        if (isOdd(product)) {
            min = BigInteger.valueOf(3);
            step = BigInteger.valueOf(numThreads).multiply(BigInteger.valueOf(2));
            inc = BigInteger.valueOf(2);
        } else {
            min = BigInteger.valueOf(2);
            step = BigInteger.valueOf(numThreads);
        }

        long start = System.nanoTime();

        Factorizer[] factorizers = new Factorizer[numThreads];
        Thread[] threads = new Thread[numThreads];

        for (int i = 0; i < numThreads; i++) {
            factorizers[i] = new Factorizer(product, min, max, step);
            min = min.add(inc);
            threads[i] = new Thread(factorizers[i]);
        }

        for (int i = 0; i < numThreads; i++) {
            threads[i].start();
        }

        for (int i = 0; i < numThreads; i++) {
            try {
                threads[i].join();
            } catch (InterruptedException e) {
                throw new RuntimeException(e);
            }
        }

        long stop = System.nanoTime();

        if (Factorizer.factor1 == null) {
            System.out.println("No factorization possible");
        } else {
            System.out.println("Factor 1: " + Factorizer.factor1);
            System.out.println("Factor 2: " + Factorizer.factor2);
        }

        double execTime = (stop - start) / 1.0E9;
        System.out.println("Time: " + execTime);
    }
}
