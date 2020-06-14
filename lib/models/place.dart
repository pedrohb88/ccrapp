class Place{

  String id;
  String name;
  String rating;
  String formatted_phone_number;
  bool open_now;
  List<dynamic> types;
  String website;

  String prevencao;
  String preco;
  String servico;
  String espera;
  String seguranca;
  String segurancaFeminina;

  Place({
    this.id,
    this.name,
    this.rating,
    this.formatted_phone_number,
    this.open_now,
    this.types,
    this.website,
    this.prevencao,
    this.preco,
    this.servico,
    this.espera,
    this.seguranca,
    this.segurancaFeminina,
  });
}