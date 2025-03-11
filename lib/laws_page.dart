import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class LawsPage extends StatelessWidget {
  // Function to open the reference link
  void _launchURL() async {
    const url = 'https://wcd.gov.in/'; // Official Ministry of Women and Child Development link
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Laws for Women Welfare & Safety'),
        backgroundColor: Colors.pinkAccent,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LawCard(
                title: "The Protection of Women from Domestic Violence Act, 2005",
                description:
                "This law provides protection to women from domestic violence and allows them to seek legal remedies, including protection orders, residence orders, and monetary relief.",
              ),
              LawCard(
                title: "The Sexual Harassment of Women at Workplace (Prevention, Prohibition and Redressal) Act, 2013",
                description:
                "This law ensures women’s safety at workplaces by setting up an internal complaints committee for redressal of grievances.",
              ),
              LawCard(
                title: "The Dowry Prohibition Act, 1961",
                description:
                "This law prohibits the giving or receiving of dowry and punishes those who demand or accept dowry before or after marriage.",
              ),
              LawCard(
                title: "The Maternity Benefit Act, 1961 (Amended 2017)",
                description:
                "Provides paid maternity leave up to 26 weeks for women in workplaces and ensures job security during the maternity period.",
              ),
              LawCard(
                title: "The Prohibition of Child Marriage Act, 2006",
                description:
                "Aims to prevent child marriages and protect the rights of young girls by setting the legal marriage age at 18 for women.",
              ),
              LawCard(
                title: "The Indian Penal Code (IPC) Sections 354, 376, 509",
                description:
                "These sections deal with crimes against women such as assault with intent to outrage modesty, rape, and sexual harassment.",
              ),
              LawCard(
                title: "The Medical Termination of Pregnancy (MTP) Act, 1971 (Amended 2021)",
                description:
                "Allows women to safely terminate pregnancies under certain legal conditions and extends abortion rights for unmarried women as well.",
              ),
              LawCard(
                title: "The Hindu Succession Act, 1956 (Amended 2005)",
                description:
                "Gives equal inheritance rights to women in ancestral property, ensuring gender equality in property ownership.",
              ),
              LawCard(
                title: "The Indecent Representation of Women (Prohibition) Act, 1986",
                description:
                "Prohibits indecent or derogatory representation of women in advertisements, publications, and online platforms.",
              ),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: _launchURL,
                  child: Text("Learn More"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pinkAccent,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    textStyle: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LawCard extends StatelessWidget {
  final String title;
  final String description;

  LawCard({required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 5),
            Text(
              description,
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
