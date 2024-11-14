import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';  // Ensure Supabase Flutter package is imported

class FeedbacksScreen extends StatefulWidget {
  const FeedbacksScreen({super.key});

  @override
  State<FeedbacksScreen> createState() => FeedbacksScreenState();
}

class FeedbacksScreenState extends State<FeedbacksScreen> {
  late final SupabaseClient supabaseClient; // Declare Supabase Client
  List<Map<String, dynamic>> reviews = [];
  bool isLoading = true; // Flag to manage loading state

  @override
  void initState() {
    super.initState();
    supabaseClient = Supabase.instance.client; // Initialize the client
    _loadReviews();
  }

  // Function to fetch reviews by service provider ID (current user ID)
  Future<void> _loadReviews() async {
    try {
      final userSession = supabaseClient.auth.currentSession;
      final userId = userSession?.user?.id; // Get current user ID

      if (userId == null) {
        // Handle the case when user is not logged in
        return;
      }

      final response = await supabaseClient
          .rpc('get_feedback_by_sp_id', params: {'sp_id_param': userId})  // Call the custom function
          .execute();

      if (response.error == null) {
        setState(() {
          reviews = List<Map<String, dynamic>>.from(response.data);
          isLoading = false; // Set isLoading to false once the data is fetched
        });
      } else {
        // Handle error (e.g., no internet or query failure)
        print('Error fetching reviews: ${response.error?.message}');
        setState(() {
          isLoading = false; // Stop loading if there is an error
        });
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        isLoading = false; // Stop loading in case of an exception
      });
    }
  }

  // Method to calculate average rating
  double calculateAverageRating() {
    if (reviews.isEmpty) return 0.0;
    double totalRating = reviews.fold(0.0, (sum, review) => sum + review['rating']);
    return totalRating / reviews.length;
  }

  @override
  Widget build(BuildContext context) {
    double averageRating = calculateAverageRating();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: isLoading
          ? const Center(  // Show a loading spinner while data is being fetched
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color.fromRGBO(209, 76, 1, 1)), // Use primary color
              ),
            )
          : ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Text(
                        "Feedback",
                        style: TextStyle(
                          fontSize: 20,
                          color: Color.fromRGBO(160, 62, 6, 1),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ...List.generate(5, (index) {
                            return Icon(
                              index < averageRating ? Icons.star : Icons.star_border,
                              color: index < averageRating
                                  ? const Color.fromRGBO(209, 76, 1, 1)
                                  : Colors.grey,
                            );
                          }),
                          const SizedBox(width: 5),
                          Text(
                            "(${averageRating.toStringAsFixed(1)})", // Display rating with one decimal point
                            style: const TextStyle(fontSize: 17),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const Text(
                            'Total:',
                            style:
                                TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            '${reviews.length}', // Display number of reviews
                            style: const TextStyle(fontSize: 18),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      // Display the reviews dynamically
                      ...reviews.map((review) {
                        return ReviewCard(
                          name: '${review['pet_owner_first_name']} ${review['pet_owner_last_name']}', // Display pet owner's full name
                          reviewText: review['review'] ?? 'No review provided',
                          rating: review['rating']?.toDouble() ?? 0.0,
                          reviewDate: review['review_date']?.toString() ?? 'No Date',
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

extension on PostgrestResponse {
  get error => null;
}

class ReviewCard extends StatelessWidget {
  final String name;
  final String reviewText;
  final double rating;
  final String reviewDate;

  const ReviewCard({
    super.key,
    required this.name,
    required this.reviewText,
    required this.rating,
    required this.reviewDate,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              reviewText,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                ...List.generate(5, (index) {
                  return Icon(
                    index < rating ? Icons.star : Icons.star_border,
                    color: index < rating
                        ? const Color.fromRGBO(209, 76, 1, 1)
                        : Colors.grey,
                  );
                }),
                const SizedBox(width: 5),
                Text(
                  "(${rating.toStringAsFixed(1)})", // Display each review's rating
                  style: const TextStyle(fontSize: 14),
                ),
                const Spacer(),
                Text(
                  reviewDate,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
