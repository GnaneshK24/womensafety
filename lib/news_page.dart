import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class NewsPage extends StatelessWidget {
  final List<Map<String, String>> newsArticles = [
    {
      "title": "Government launches new women safety initiative",
      "image": "https://i.poweredtemplates.com/p/sp/83297/sp_slide_h_1.jpg",
      "url": "https://www.insightsonindia.com/2025/02/11/government-initiatives-to-support-women-employees-and-entrepreneurs/"
    },
    {
      "title": "Empowering women through education",
      "image": "https://static.vecteezy.com/system/resources/previews/001/410/769/original/confident-women-on-supporting-equality-free-vector.jpg",
      "url": "https://www.niti.gov.in/empowerment-women-through-education-skilling-micro-financing"
    },
    {
      "title": "How technology is making the world safer for women",
      "image": "https://images.unsplash.com/photo-1488590528505-98d2b5aba04b?q=80&w=1170&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
      "url": "https://www.yodda.care/post/women-s-safety-in-2025-how-technology-is-changing-the-way-we-react-to-situations"
    },
    {
      "title": "New self-defense training programs for women",
      "image": "https://images.unsplash.com/photo-1577998555981-6e798325914e?q=80&w=1162&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
      "url": "https://www.cheshiredisability.org/self-defence-for-women/"
    },
    {
      "title": "Women entrepreneurs are leading startups worldwide",
      "image": "https://images.unsplash.com/photo-1555834841-c97de033abd6?q=80&w=736&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
      "url": "https://www.lcca.org.uk/blog/business/the-rise-of-women-led-start-ups-and-their-impact/"
    },
    {
      "title": "Stronger laws for women's safety introduced",
      "image": "https://images.yourstory.com/cs/wordpress/2017/03/Featured-image-7-1.jpg",
      "url": "https://economictimes.indiatimes.com/news/politics-and-nation/womens-safety-our-govts-top-priority-we-made-strict-laws-to-prevent-crimes-against-them-pm-modi/articleshow/118804184.cms"
    }
  ];

  void _openNews(String url) async {
    Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      debugPrint("Could not open $url");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Women Welfare News")),
      body: ListView.builder(
        itemCount: newsArticles.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => _openNews(newsArticles[index]["url"]!),
            child: Card(
              margin: EdgeInsets.all(10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                    child: Image.network(
                      newsArticles[index]["image"]!,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(child: CircularProgressIndicator());
                      },
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 200,
                        color: Colors.grey[300],
                        child: Center(child: Icon(Icons.broken_image, size: 50, color: Colors.grey)),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: Text(
                      newsArticles[index]["title"]!,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
