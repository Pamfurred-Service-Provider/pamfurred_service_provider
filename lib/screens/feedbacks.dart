import 'package:flutter/material.dart';

class FeedbacksScreen extends StatefulWidget {
  const FeedbacksScreen({super.key});

  @override
  State<FeedbacksScreen> createState() => FeedbacksScreenState();
}

class FeedbacksScreenState extends State<FeedbacksScreen> {
  final double staticRating = 3.0; // Static average rating
  final List<Review> reviews = [
    Review(
      name: "John Doe",
      reviewText: "Great service, very satisfied!",
      rating: 4.0,
      reviewDate: "2024-10-01",
    ),
    Review(
      name: "Jane Smith",
      reviewText: "It was okay, nothing special.",
      rating: 2.5,
      reviewDate: "2024-10-02",
    ),
    Review(
      name: "Alice Johnson",
      reviewText: "Absolutely loved it! Highly recommend.",
      rating: 5.0,
      reviewDate: "2024-10-03",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: ListView(
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
                        index < staticRating ? Icons.star : Icons.star_border,
                        color:
                            index < staticRating ? Colors.yellow : Colors.grey,
                      );
                    }),
                    const SizedBox(width: 5),
                    Text(
                      "(${staticRating.toStringAsFixed(1)})", // Display rating with one decimal point
                      style: const TextStyle(fontSize: 17),
                    ),
                  ],
                ),
                const SizedBox(height: 20), // Space before total label
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Text(
                      'Total:',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                        width: 5), // Space between total label and number
                    Text(
                      '${reviews.length}', // Display number of reviews
                      style: const TextStyle(fontSize: 18),
                    ),
                  ],
                ),
                const SizedBox(height: 10), // Space after total label
                // Here you can add static review cards
                ...reviews.map((review) => ReviewCard(
                      name: review.name,
                      reviewText: review.reviewText,
                      rating: review.rating,
                      reviewDate: review.reviewDate,
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
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
              name, // Name with asterisks for security
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              reviewText, // Review text
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                ...List.generate(5, (index) {
                  return Icon(
                    index < rating ? Icons.star : Icons.star_border,
                    color: index < rating ? Colors.yellow : Colors.grey,
                  );
                }),
                const SizedBox(width: 5),
                Text(
                  "(${rating.toStringAsFixed(1)})", // Display each review's rating
                  style: const TextStyle(fontSize: 14),
                ),
                const Spacer(),
                Text(
                  reviewDate, // Review date
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

class Review {
  final String name;
  final String reviewText;
  final double rating;
  final String reviewDate;

  Review({
    required this.name,
    required this.reviewText,
    required this.rating,
    required this.reviewDate,
  });
}
