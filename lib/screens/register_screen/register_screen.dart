import 'package:ccrapp/components/custom_dialog.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:ccrapp/models/api.dart';
import 'package:ccrapp/models/user.dart';
import 'package:ccrapp/components/loader.dart';

final colorYellow = Color(0xFFFFC100);
final marginBottom = EdgeInsets.only(bottom: 8.0);

final colorYellowColor = Color(0xFFFFC100);
final myBlack = Color(0xFF323232);

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  String _phase;
  bool _alreadyRegistered;
  bool _loading = false;

  String _phone;
  String _name;
  String _verificationCode;

  final _formKey = GlobalKey<FormState>();
  double inputHeight = 45.0;

  @override
  void initState() {
    super.initState();

    _phase = 'waitingPhone';
  }

  _buildPhoneForm() {
    return Column(
        children: <Widget>[
      Text(
        'Cadastre-se',
        style: TextStyle(
            color: myBlack, fontWeight: FontWeight.bold, fontSize: 32.0),
      ),
      Text(
        'Digite seu telefone e use grátis',
        style: TextStyle(
          color: myBlack,
        ),
      ),
      Column(
          children: [
        Form(
          key: _formKey,
          child: Column(
            children: [
              Container(
                margin: marginBottom,
                height: inputHeight,
                width: double.infinity,
                child: TextFormField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.all(10.0),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: colorYellow),
                    ),
                    hintText: 'Fulano de tal',
                    labelText: 'Nome',
                    labelStyle: TextStyle(color: colorYellow),
                  ),
                  onChanged: (value) {
                    value = value.trim();
                    setState(() {
                      _name = value;
                    });
                  },
                ),
              ),
              Container(
                margin: marginBottom,
                height: inputHeight,
                width: double.infinity,
                child: TextFormField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.all(10.0),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: colorYellow),
                    ),
                    hintText: 'ex: 22999999999',
                    labelText: 'Telefone',
                    labelStyle: TextStyle(color: colorYellow),
                  ),
                  onChanged: (value) {
                    value = value.trim();
                    setState(() {
                      _phone = value;
                    });
                  },
                ),
              ),
              Container(
                margin: marginBottom,
                height: 40.0,
                width: double.infinity,
                child: RaisedButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0)),
                  textColor: Colors.white,
                  onPressed: () {
                    setState(() {
                      _loading = true;
                    });
                    Api().sendVerificationCode(_phone).then((result) {
                      setState(() {
                        _loading = false;
                      });

                      if (result['success']) {
                        setState(() {
                          _phase = 'waitingCode';
                          _alreadyRegistered = result['alreadyRegistered'];
                        });
                      } else {
                        CustomDialog(
                            msg:
                                'Falha ao enviar código de autenticação. Tem certeza que o celular informado é válido?')
                          ..show(context);
                      }
                      return null;
                    });
                  },
                  color: colorYellow,
                  child: Text('Continuar', style: TextStyle(color: myBlack),),
                ),
              ),
            ],
          ),
        ),
      ].map((w) {
        return Container(
          child: w,
          margin: EdgeInsets.only(top: 16.0),
        );
      }).toList()),
    ].map((w) {
      return Container(
        child: w,
        margin: EdgeInsets.only(top: 16.0),
      );
    }).toList());
  }

  _buildCodeForm() {
    return Container(
        margin: EdgeInsets.only(top: 16.0),
        child: Column(
            children: <Widget>[
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(style: TextStyle(color: Colors.black), children: [
              TextSpan(text: 'Enviamos um código de verificação para'),
              TextSpan(
                  style: TextStyle(fontWeight: FontWeight.bold, height: 1.5),
                  text: '\n$_phone\n '),
              TextSpan(text: 'É só inserir ele aqui pra continuar.'),
            ]),
          ),
          Column(
              children: [
            Form(
              child: Column(
                children: [
                  Container(
                    margin: marginBottom,
                    height: inputHeight,
                    width: double.infinity,
                    child: TextFormField(
                      onChanged: (value) {
                        setState(() {
                          _verificationCode = value;
                        });
                      },
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(10.0),
                        border: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: colorYellow),
                        ),
                        hintText: 'XXXX',
                        labelText: 'Código',
                        labelStyle: TextStyle(color: colorYellow),
                      ),
                    ),
                  ),
                  Container(
                    height: 40.0,
                    width: double.infinity,
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          flex: 1,
                          child: RaisedButton(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            textColor: Colors.white,
                            onPressed: () async {
                              setState(() {
                                _phase = 'waitingPhone';
                              });
                            },
                            color: Colors.grey,
                            child: Text('Voltar'),
                          ),
                        ),
                        SizedBox(
                          width: 18.0,
                        ),
                        Expanded(
                          flex: 1,
                          child: Consumer<User>(
                            builder: (context, user, child) {
                              return RaisedButton(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5.0),
                                ),
                                textColor: Colors.white,
                                onPressed: () async {
                                  setState(() {
                                    _loading = true;
                                  });

                                  if (_alreadyRegistered) {
                                    final result = await user.login(
                                        _phone, _verificationCode);
                                    print(result);
                                    setState(() {
                                      _loading = false;
                                    });

                                    if (!result)
                                      CustomDialog(
                                          msg:
                                              'Falha ao entrar: Código inválido')
                                        ..show(context);
                                  } else {
                                    final result = await user.verifyCode(
                                        _phone, _verificationCode);

                                    if (!result) {
                                      setState(() {
                                        _loading = false;
                                      });
                                      CustomDialog(
                                          msg:
                                              'Falha no cadastro: Código inválido')
                                        ..show(context);
                                    } else {
                                      final result = await user.register(
                                          name: _name,
                                          phone: _phone,
                                          verificationCode: _verificationCode);
                                      setState(() {
                                        _loading = false;
                                      });

                                      if (!result)
                                        CustomDialog(
                                            msg: 'Falha ao realizar cadastro')
                                          ..show(context);

                                      setState(() {
                                        _phase = 'completed';
                                      });
                                    }
                                  }
                                },
                                color: colorYellow,
                                child: Text('Continuar'),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ].map((w) {
            return Container(
              child: w,
              margin: EdgeInsets.only(top: 16.0),
            );
          }).toList()),
        ].map((w) {
          return Container(
            child: w,
            margin: EdgeInsets.only(top: 16.0),
          );
        }).toList()));
  }

  @override
  Widget build(BuildContext context) {
    Widget currentWidget;
    switch (_phase) {
      case 'waitingPhone':
        currentWidget = _buildPhoneForm();
        break;
      case 'waitingCode':
        currentWidget = _buildCodeForm();
        break;
      default:
        break;
    }
    return Scaffold(
      body: SingleChildScrollView(
        child: Stack(
          children: <Widget>[
            Container(
              height: MediaQuery.of(context).size.height,
              child: Column(
                children: <Widget>[
                  Expanded(
                    flex: 4,
                    child: Center(
                      child: Image.asset('assets/images/logo.png'),
                    ),
                  ),
                  Expanded(
                    flex: 6,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 50.0, vertical: 10.0),
                      child: SingleChildScrollView(child: currentWidget),
                    ),
                  ),
                ],
              ),
            ),
            if (_loading) Loader(fullScreen: true),
          ],
        ),
      ),
    );
  }
}
