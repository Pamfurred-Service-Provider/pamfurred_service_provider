import 'package:flutter/material.dart';

class FeedbacksScreen extends StatefulWidget {
  const FeedbacksScreen({super.key});

  @override
  State<FeedbacksScreen> createState() => FeedbacksScreenState();
}

class FeedbacksScreenState extends State<FeedbacksScreen> {
  final List<Map<String, dynamic>> reviews = [
    {
      "name": "John ",
      "review": "Great service!",
      "rating": 4,
      "date": "2024-10-20"
    },
    {
      "name": "Jane ",
      "review": "Could be better.",
      "rating": 3,
      "date": "2024-10-19"
    },
    {
      "name": "Alex ",
      "review": "Loved the care my pet received.",
      "rating": 4,
      "date": "2024-10-18"
    },
    {
      "name": "Alex ",
      "review": "Loved the care my pet received.",
      "rating": 1,
      "date": "2024-10-18"
    },
  ];
// Method to calculate average rating //found tapad sa stars, ubos sa text
  double calculateAverageRating() {
    if (reviews.isEmpty) return 0.0;
    double totalRating =
        reviews.fold(0.0, (sum, review) => sum + review['rating']);
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
                ...reviews.map((review) {
                  return ReviewCard(
                    name: review['name'],
                    reviewText: review['review'],
                    rating: review['rating'].toDouble(),
                    reviewDate: review['date'],
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
