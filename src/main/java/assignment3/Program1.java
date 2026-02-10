// Albin Phillips

// [Do necessary modifications of this file.]

package assignment3;

// [You are welcome to add some import statements.]

import java.util.concurrent.ArrayBlockingQueue;
import java.util.concurrent.BlockingQueue;
import java.util.concurrent.ForkJoinPool;

public class Program1 {
	final static int NUM_WEBPAGES = 40;
	private static final WebPage[] webPages = new WebPage[NUM_WEBPAGES];
	// [You are welcome to add some variables.]
	private static final BlockingQueue<WebPage> downloaded = new ArrayBlockingQueue<>(NUM_WEBPAGES);
	private static final BlockingQueue<WebPage> analyzed = new ArrayBlockingQueue<>(NUM_WEBPAGES);
	private static final BlockingQueue<WebPage> categorized = new ArrayBlockingQueue<>(NUM_WEBPAGES);

	// [You are welcome to modify this method, but it should NOT be parallelized.]
	private static void initialize() {
		for (int i = 0; i < NUM_WEBPAGES; i++) {
			webPages[i] = new WebPage(i, "http://www.site.se/page" + i + ".html");
		}
	}
	
	// [Do modify this sequential part of the program.]
	private static void downloadWebPages() {
		ForkJoinPool pool = ForkJoinPool.commonPool();
		pool.execute(() -> {
			try {
				for (int i = 0; i < NUM_WEBPAGES; i++) {
					webPages[i].download();
					downloaded.put(webPages[i]);
				}
			} catch (InterruptedException e) {
                Thread.currentThread().interrupt();
            }
        });
	}
	
	// [Do modify this sequential part of the program.]
	private static void analyzeWebPages() {
		ForkJoinPool pool = ForkJoinPool.commonPool();
		pool.execute(() -> {
			try {
				for (int i = 0; i < NUM_WEBPAGES; i++) {
					WebPage page = downloaded.take();
					page.analyze();
					analyzed.put(page);
				}
			} catch (InterruptedException e) {
                Thread.currentThread().interrupt();
            }
        });
	}
	
	// [Do modify this sequential part of the program.]
	private static void categorizeWebPages() {
		ForkJoinPool pool = ForkJoinPool.commonPool();
		pool.execute(() -> {
			try {
				for (int i = 0; i < NUM_WEBPAGES; i++) {
					WebPage page = analyzed.take();
					page.categorize();
					categorized.put(page);
				}
			} catch (InterruptedException e) {
                Thread.currentThread().interrupt();
            }
        });
	}
	
	// [You are welcome to modify this method, but it should NOT be parallelized.]
	private static void presentResult() {
		for (int i = 0; i < NUM_WEBPAGES; i++) {
            try {
                System.out.println(categorized.take());
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
            }
        }
	}
	
	public static void main(String[] args) {
		// Initialize the list of webpages.
		initialize();
		
		// Start timing.
		long start = System.nanoTime();

		// Do the work.
		downloadWebPages();
		analyzeWebPages();
		categorizeWebPages();

		// Present the result.
		presentResult();

		// Stop timing.
		long stop = System.nanoTime();
		
		// Present the execution time.
		System.out.println("Execution time (seconds): " + (stop - start) / 1.0E9);
	}
}
