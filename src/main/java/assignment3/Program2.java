// Albin Phillips
// [Do necessary modifications of this file.]

package assignment3;

// [You are welcome to add some import statements.]

import java.util.Arrays;

public class Program2 {
	final static int NUM_WEBPAGES = 40;
	private static WebPage[] webPages = new WebPage[NUM_WEBPAGES];
	// [You are welcome to add some variables.]

	// [You are welcome to modify this method, but it should NOT be parallelized.]
	private static void initialize() {
		for (int i = 0; i < NUM_WEBPAGES; i++) {
			webPages[i] = new WebPage(i, "http://www.site.se/page" + i + ".html");
		}
	}
	
	// [Do modify this sequential part of the program.]
	private static void downloadWebPages() {
		Arrays.stream(webPages).parallel().forEach(WebPage::download);
	}
	
	// [Do modify this sequential part of the program.]
	private static void analyzeWebPages() {
		Arrays.stream(webPages).parallel().forEach(WebPage::analyze);
	}
	
	// [Do modify this sequential part of the program.]
	private static void categorizeWebPages() {
		Arrays.stream(webPages).parallel().forEach(WebPage::categorize);
	}
	
	// [You are welcome to modify this method, but it should NOT be parallelized.]
	private static void presentResult() {
		for (int i = 0; i < NUM_WEBPAGES; i++) {
			System.out.println(webPages[i]);
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
		
		// Stop timing.
		long stop = System.nanoTime();

		// Present the result.
		presentResult();
		
		// Present the execution time.
		System.out.println("Execution time (seconds): " + (stop - start) / 1.0E9);
	}
}
