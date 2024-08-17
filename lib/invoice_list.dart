import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'invoice.dart';
import 'pdf_viewer_page.dart';
import 'DataService.dart';
import 'package:intl/intl.dart';

class InvoiceList extends StatefulWidget {
  @override
  _InvoiceListState createState() => _InvoiceListState();
}

class _InvoiceListState extends State<InvoiceList> {
  DataService dataService = DataService();
  List<Invoice> invoices = [];

  @override
  void initState() {
    super.initState();
    fetchInvoices(); // Fetch invoices when widget initializes
  }

  void fetchInvoices() async {


      // Replace 'clientId' with actual client ID or pass it as parameter
      List<Invoice> fetchedInvoices = await dataService.fetchInvoicesByClient();

      setState(() {
        invoices = fetchedInvoices; // Update state with fetched invoices
      });

  }

  void _validateInvoice(int index) {
    List<Invoice> invoicesup = invoices;
    dataService.validateFacture(invoices[index].idF).then((_) {
      invoicesup[index].status="Proforma_envoyee_validee";
      setState(() {
        invoices = invoicesup;
      });
      // Handle success, e.g., show a success message or navigate back
      ScaffoldMessenger.of(context).showSnackBar(

        SnackBar(
          content: Text('Proforma validée avec succées'),
          duration: Duration(seconds: 2),
        ),
      );
    }).catchError((error) {
      // Handle errors, e.g., show an error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to validate facture: $error'),
          duration: Duration(seconds: 2),
        ),
      );
    });
  }

  void _denyInvoice(int index) {
    List<Invoice> invoicesup = invoices;

    dataService.DenyFacture(invoices[index].idF).then((_) {
      invoicesup[index].status="Proforma_envoyee_Refusee";
      setState(() {
        invoices = invoicesup;
      });
      // Handle success, e.g., show a success message or navigate back
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Proforma refusée avec succées'),
          duration: Duration(seconds: 2),
        ),
      );
    }).catchError((error) {
      // Handle errors, e.g., show an error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to validate facture: $error'),
          duration: Duration(seconds: 2),
        ),
      );
    });
  }

  void __pdf(int id) async{
    await dataService.DisplayFacture(context,id);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        appBar: AppBar(

        title: Text('Factures',
            style: TextStyle(color: Colors.white)),
          leading: IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(FontAwesomeIcons.angleLeft),
            color: Colors.white,
          ),
    backgroundColor: Colors.blueAccent,
    ),
    body: Container(
    decoration: BoxDecoration(
    gradient: LinearGradient(
    colors: [Colors.blue[50]!, Colors.blue[100]!],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    ),
    ),
    child: ListView.builder(
    padding: EdgeInsets.all(8.0),
    itemCount: invoices.length,
    itemBuilder: (context, index) {
      String currencySymbol = invoices[index].type == "export" ? "€" : "TND";
      DateTime invoiceDate = invoices[index].dateemission; // Assuming date is of type DateTime
      String formattedDate = DateFormat('dd-MM-yyyy').format(invoiceDate);
    return Card(
    margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
    elevation: 10.0,
    shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(20.0),
    ),
    child: Container(
    decoration: BoxDecoration(
    gradient: LinearGradient(
    colors: [Colors.white, Colors.blue[50]!],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    ),
    borderRadius: BorderRadius.circular(20.0),
    boxShadow: [
    BoxShadow(
    color: Colors.black26,
    blurRadius: 10.0,
    spreadRadius: 1.0,
    offset: Offset(0, 5),
    ),
    ],
    ),
    child: ListTile(
    contentPadding: EdgeInsets.all(16.0),
    leading: CircleAvatar(
    backgroundColor: Colors.white,
    child: Text(
    invoices[index].number.toString(),
    style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold),
    ),
    ),
    title: Text(
        invoices[index].status == "Facture" || invoices[index].status == "Facture_envoye" || invoices[index].status == "Facture_valide"
            ? 'Facture ${invoices[index].number.toString()}'
            : 'Proforma ${invoices[index].number.toString()}',
    style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold, color: Colors.blueAccent),
    ),
    subtitle: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    SizedBox(height: 8.0),
    Text('Montant: ${invoices[index].totalttc.toStringAsFixed(2)} $currencySymbol', style: TextStyle(fontSize: 16.0, color: Colors.blueGrey)),
    Divider(color: Colors.blueGrey),
    Text('Date: $formattedDate', style: TextStyle(fontSize: 16.0, color: Colors.blueGrey)),
    SizedBox(height: 8.0),
    Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
    if (invoices[index].status == 'Proforma_envoyee') ...[
    ElevatedButton.icon(
    icon: Icon(FontAwesomeIcons.check, color: Colors.white),
    label: Text('Valider', style: TextStyle(color: Colors.white)),
    style: ElevatedButton.styleFrom(
    backgroundColor: Colors.green,
    shadowColor: Colors.greenAccent,
    elevation: 5,
    shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(10.0),
    side: BorderSide(color: Colors.green),
    ),
    ),
    onPressed: () => _validateInvoice(index),
    ),
    ElevatedButton.icon(
    icon: Icon(FontAwesomeIcons.xmark, color: Colors.white),
    label: Text('Refuser', style: TextStyle(color: Colors.white)),
    style: ElevatedButton.styleFrom(
    backgroundColor: Colors.red,
    shadowColor: Colors.redAccent,
    elevation: 5,
    shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(10.0),
    side: BorderSide(color: Colors.red),
    ),
    ),
    onPressed: () => _denyInvoice(index),
    ),
    ],
    if (invoices[index].status == 'Proforma_envoyee_validee') Icon(FontAwesomeIcons.checkCircle, color: Colors.green, size: 30.0),
    if (invoices[index].status == 'Proforma_envoyee_Refusee') Icon(FontAwesomeIcons.timesCircle, color: Colors.red, size: 30.0),
    ],
    ),
    ],
    ),
      onTap: () {
        int id = invoices[index].idF;
        __pdf(id);

      }


    ),
    ),
    );
    },
    ),
    ),
    );
  }
}
