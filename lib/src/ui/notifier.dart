import 'package:flutter/material.dart';
import '../subject/value.dart';

extension PublisherTextEditingController on TextEditingController {
  CurrentValueSubject<String, Never> get publisher {
    final subject = CurrentValueSubject<String, Never>(text);
    addListener(() {
      subject.send(text);
    });
    return subject;
  }
}

extension PublisherTabController on TabController {
  CurrentValueSubject<int, Never> get publisher {
    final subject = CurrentValueSubject<int, Never>(index);
    addListener(() {
      subject.send(index);
    });
    return subject;
  }
}

extension PublisherPageController on PageController {
  CurrentValueSubject<int, Never> get publisher {
    int? _page;
    if (hasClients) {
      _page = page?.toInt();
    }
    final subject = CurrentValueSubject<int, Never>(_page ?? initialPage);
    addListener(() {
      double? _page = page;
      if (_page != null) {
        subject.send(_page.toInt());
      }
    });
    return subject;
  }
}
