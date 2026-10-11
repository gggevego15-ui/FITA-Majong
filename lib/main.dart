import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'game/mahjong_rules.dart';

import 'services/auth_service.dart';
import 'services/progress_store.dart';
import 'services/multiplayer_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AuthService.instance.initialize();
  runApp(const FitaMahjongApp());
}

String _tr(String language, String key) {
  const t = <String, List<String>>{
    'welcomeTitle':['A little calm,\none tile at a time.','Немного покоя —\nпо одной фишке.','Un poco de calma,\nuna ficha a la vez.','Un peu de calme,\nune tuile à la fois.','Ein wenig Ruhe,\nStein für Stein.','Um pouco de calma,\numa peça de cada vez.','Un po’ di calma,\nuna tessera alla volta.','Biraz huzur,\nher seferinde bir taş.','慢下来，\n一次配对一块牌。','少しずつ、\n一枚ずつ穏やかに。','조금씩 천천히,\n타일 하나씩.','थोड़ा सुकून,\nएक बार में एक टाइल।','قليل من الهدوء،\nقطعة في كل مرة.'],
    'welcomeSubtitle':['Find your rhythm in a garden of puzzles.','Найди свой ритм в саду головоломок.','Encuentra tu ritmo en un jardín de puzzles.','Trouve ton rythme dans un jardin de puzzles.','Finde deinen Rhythmus im Rätselgarten.','Encontre seu ritmo num jardim de enigmas.','Trova il tuo ritmo nel giardino dei rompicapi.','Bulmaca bahçesinde kendi ritmini bul.','在花园般的谜题中找到自己的节奏。','パズルの庭で自分のリズムを見つけよう。','퍼즐 정원에서 나만의 리듬을 찾아보세요.','पहेलियों के बगीचे में अपनी लय खोजें।','اعثر على إيقاعك في حديقة الألغاز.'],
    'pleaseWait':['Please wait…','Подожди…','Espera…','Patiente…','Bitte warten…','Aguarde…','Attendi…','Lütfen bekle…','请稍候…','お待ちください…','잠시만 기다려 주세요…','कृपया प्रतीक्षा करें…','يرجى الانتظار…'],
    'play':['Play','Играть','Jugar','Jouer','Spielen','Jogar','Gioca','Oyna','开始','プレイ','플레이','खेलें','العب'],
    'guestNote':['No account needed. Your journey starts here.','Аккаунт не нужен. Твоё путешествие начинается здесь.','No necesitas cuenta. Tu aventura empieza aquí.','Aucun compte nécessaire. Ton aventure commence ici.','Kein Konto nötig. Deine Reise beginnt hier.','Não precisa de conta. Sua jornada começa aqui.','Non serve un account. Il viaggio inizia qui.','Hesap gerekmez. Yolculuğun burada başlıyor.','无需账号，旅程从这里开始。','アカウント不要。ここから旅が始まります。','계정이 필요 없어요. 여기서 여정이 시작됩니다.','खाते की ज़रूरत नहीं। आपकी यात्रा यहीं से शुरू होती है।','لا تحتاج إلى حساب. تبدأ رحلتك من هنا.'],
    'goodDay':['GOOD DAY, PLAYER','ДОБРОГО ДНЯ, ИГРОК','BUEN DÍA, JUGADOR','BONJOUR, JOUEUR','GUTEN TAG, SPIELER','BOM DIA, JOGADOR','BUONGIORNO, GIOCATORE','İYİ GÜNLER OYUNCU','玩家，今天好','こんにちは、プレイヤー','좋은 하루예요, 플레이어','नमस्ते खिलाड़ी','مرحبًا أيها اللاعب'],
    'quietCorner':['Your quiet corner','Твой тихий уголок','Tu rincón tranquilo','Ton coin tranquille','Dein ruhiger Ort','Seu canto tranquilo','Il tuo angolo tranquillo','Sakin köşen','你的宁静角落','あなたの静かな場所','나만의 조용한 공간','आपका शांत कोना','ركنك الهادئ'],
    'gardenPath':['THE GARDEN PATH','ТРОПА САДА','EL CAMINO DEL JARDÍN','LE CHEMIN DU JARDIN','DER GARTENPFAD','O CAMINHO DO JARDIM','IL SENTIERO DEL GIARDINO','BAHÇE YOLU','花园小径','庭園の小道','정원 길','बगीचे का रास्ता','مسار الحديقة'],
    'freshPuzzle':['A fresh puzzle\nawaits you.','Новая головоломка\nуже ждёт тебя.','Un nuevo puzzle\nte espera.','Un nouveau puzzle\nt’attend.','Ein neues Rätsel\nwartet auf dich.','Um novo desafio\nespera por você.','Un nuovo puzzle\nti aspetta.','Yeni bir bulmaca\nseni bekliyor.','新的谜题\n正在等你。','新しいパズルが\n待っています。','새 퍼즐이\n기다리고 있어요.','एक नई पहेली\nआपका इंतज़ार कर रही है।','لغز جديد\nبانتظارك.'],
    'continue':['Continue','Продолжить','Continuar','Continuer','Weiter','Continuar','Continua','Devam et','继续','続ける','계속하기','जारी रखें','متابعة'],
    'level':['Level','Уровень','Nivel','Niveau','Level','Nível','Livello','Seviye','关卡','レベル','레벨','स्तर','المستوى'],
    'yourJourney':['YOUR JOURNEY','ТВОЙ ПУТЬ','TU CAMINO','TON PARCOURS','DEINE REISE','SUA JORNADA','IL TUO VIAGGIO','YOLCULUĞUN','你的旅程','あなたの旅','나의 여정','आपकी यात्रा','رحلتك'],
    'dailyDew':['Daily dew','Капля дня','Reto diario','Défi du jour','Tagesrätsel','Desafio diário','Sfida quotidiana','Günlük görev','每日挑战','デイリーチャレンジ','오늘의 도전','दैनिक चुनौती','تحدي اليوم'],
    'dailyChallenge':['A tiny daily challenge','Небольшое ежедневное испытание','Un pequeño reto cada día','Un petit défi quotidien','Eine kleine tägliche Herausforderung','Um pequeno desafio por dia','Una piccola sfida al giorno','Küçük bir günlük meydan okuma','每天一个小挑战','毎日の小さな挑戦','매일 작은 도전','हर दिन एक छोटी चुनौती','تحدٍ يومي صغير'],
    'trailRanks':['Trail ranks','Рейтинг тропы','Clasificación','Classement','Rangliste','Classificação','Classifica','Sıralama','排行榜','ランキング','순위표','लीडरबोर्ड','لوحة المتصدرين'],
    'climbLeaderboard':['Climb the leaderboard','Поднимайся в таблице лидеров','Sube en la tabla de líderes','Grimpe dans le classement','Steige in der Rangliste auf','Suba na tabela de líderes','Scala la classifica','Liderlik tablosunda yüksel','冲击排行榜','ランキングを上げよう','순위를 올려보세요','रैंकिंग में ऊपर जाएँ','تقدم في الترتيب'],
    'playFriend':['Play with a friend','Играть с другом','Jugar con un amigo','Jouer avec un ami','Mit Freunden spielen','Jogar com um amigo','Gioca con un amico','Arkadaşınla oyna','与朋友一起玩','友達とプレイ','친구와 플레이','दोस्त के साथ खेलें','العب مع صديق'],
    'sameLayout':['Race through the same layout','Соревнуйтесь на одной раскладке','Compite con el mismo tablero','Défiez-vous sur la même grille','Spielt dasselbe Layout','Compitam no mesmo tabuleiro','Sfida sullo stesso schema','Aynı düzen üzerinde yarış','在相同牌局中竞赛','同じ盤面で競争','같은 배치에서 경쟁하기','एक ही बोर्ड पर मुकाबला करें','تنافسا على التخطيط نفسه'],
    'levelPath':['Level path','Путь уровней','Ruta de niveles','Parcours des niveaux','Levelpfad','Caminho dos níveis','Percorso livelli','Seviye yolu','关卡路线','レベルの道','레벨 경로','स्तरों का रास्ता','مسار المستويات'],
    'chapters':['10 chapters · 10,000 puzzles','10 глав · 10 000 головоломок','10 capítulos · 10.000 puzzles','10 chapitres · 10 000 puzzles','10 Kapitel · 10.000 Rätsel','10 capítulos · 10.000 desafios','10 capitoli · 10.000 puzzle','10 bölüm · 10.000 bulmaca','10章 · 10,000个谜题','10章 · 10,000パズル','10개 챕터 · 퍼즐 10,000개','10 अध्याय · 10,000 पहेलियाँ','10 فصول · 10,000 لغز'],
    'tileGarden':['Tile garden','Сад фишек','Jardín de fichas','Jardin de tuiles','Steingarten','Jardim de peças','Giardino di tessere','Taş bahçesi','麻将牌花园','牌の庭','타일 정원','टाइल बगीचा','حديقة القطع'],
    'exploreTiles':['Explore patterns and tile sets','Узоры и наборы фишек','Explora patrones y fichas','Explore les motifs et les tuiles','Muster und Steinsätze entdecken','Explore padrões e conjuntos','Esplora motivi e tessere','Desenleri ve taş setlerini keşfet','探索图案和牌组','模様と牌セットを探そう','패턴과 타일 세트 탐험','पैटर्न और टाइल सेट देखें','استكشف الأنماط ومجموعات القطع'],
    'breathe':['Breathe in. Match two. Breathe out.','Вдохни. Найди пару. Выдохни.','Respira. Encuentra dos. Exhala.','Respire. Trouve une paire. Expire.','Atmen. Zwei finden. Ausatmen.','Respire. Combine duas. Expire.','Respira. Abbina due. Espira.','Nefes al. İkiliyi eşleştir. Nefes ver.','深呼吸。配对两张。慢慢呼气。','息を吸って、二枚を合わせ、吐く。','숨을 쉬고, 두 개를 맞추고, 내쉬세요.','साँस लें। दो मिलाएँ। साँस छोड़ें।','تنفس. طابق قطعتين. ازفر.'],
    'guestError':['Guest mode could not start','Не удалось запустить гостевой режим','No se pudo iniciar el modo invitado','Impossible de lancer le mode invité','Gastmodus konnte nicht gestartet werden','Não foi possível iniciar o modo visitante','Impossibile avviare la modalità ospite','Misafir modu başlatılamadı','无法启动访客模式','ゲストモードを開始できませんでした','게스트 모드를 시작할 수 없어요','अतिथि मोड शुरू नहीं हो सका','تعذر بدء وضع الضيف'],
    'levels':['Levels','Уровни','Niveles','Niveaux','Level','Níveis','Livelli','Seviyeler','关卡','レベル','레벨','स्तर','المستويات'],
    'player':['Player','Игрок','Jugador','Joueur','Spieler','Jogador','Giocatore','Oyuncu','玩家','プレイヤー','플레이어','खिलाड़ी','اللاعب'],
    'completed':['Completed','Пройдено','Completado','Terminé','Abgeschlossen','Concluído','Completato','Tamamlandı','已完成','クリア済み','완료','पूरा हुआ','مكتمل'],
    'language':['Language / Язык','ЯЗЫК','IDIOMA','LANGUE','SPRACHE','IDIOMA','LINGUA','DİL','语言','言語','언어','भाषा','اللغة'],
    'settings':['Settings','Настройки','Ajustes','Paramètres','Einstellungen','Configurações','Impostazioni','Ayarlar','设置','設定','설정','सेटिंग्स','الإعدادات'],
    'sound':['Sound effects','Звуковые эффекты','Efectos de sonido','Effets sonores','Soundeffekte','Efeitos sonoros','Effetti sonori','Ses efektleri','音效','効果音','효과음','ध्वनि प्रभाव','المؤثرات الصوتية'],
    'comboEffects':['Combo effects','Эффекты комбо','Efectos de combo','Effets de combo','Combo-Effekte','Efeitos de combo','Effetti combo','Kombo efektleri','连击特效','コンボ効果','콤보 효과','कॉम्बो प्रभाव','تأثيرات الكومبو'],
    'comboEffectsNote':['Enhanced sounds and flashes at x3, x5 and x10 streaks.','Усиленные звуки и вспышки на сериях x3, x5 и x10.','Sonidos y destellos mejorados en rachas x3, x5 y x10.','Sons et éclats renforcés aux séries x3, x5 et x10.','Verstärkte Töne und Blitze bei Serien x3, x5 und x10.','Sons e brilhos reforçados nas sequências x3, x5 e x10.','Suoni e lampi potenziati nelle serie x3, x5 e x10.','x3, x5 ve x10 serilerinde güçlendirilmiş sesler ve parlamalar.','连续配对达到 x3、x5 和 x10 时增强音效与闪光。','x3、x5、x10連続時に音とフラッシュを強化します。','x3, x5, x10 연속 매치에서 사운드와 섬광을 강화합니다.','x3, x5 और x10 लगातार जोड़ियों पर बेहतर ध्वनि और चमक।','أصوات وومضات أقوى عند سلاسل x3 وx5 وx10.'],
    'haptics':['Haptic feedback','Виброотклик','Respuesta háptica','Retour haptique','Haptisches Feedback','Resposta tátil','Feedback aptico','Dokunsal geri bildirim','触觉反馈','触覚フィードバック','햅틱 피드백','हैप्टिक प्रतिक्रिया','الاستجابة اللمسية'],
    'backgroundTheme':['BACKGROUND THEME','ТЕМА ФОНА','TEMA DE FONDO','THÈME DE FOND','HINTERGRUNDTHEMA','TEMA DE FUNDO','TEMA SFONDO','ARKA PLAN TEMASI','背景主题','背景テーマ','배경 테마','पृष्ठभूमि थीम','سمة الخلفية'],
    'tileStyle':['TILE STYLE','СТИЛЬ ФИШЕК','ESTILO DE FICHAS','STYLE DES TUILES','STEINSTIL','ESTILO DAS PEÇAS','STILE TESSERE','TAŞ STİLİ','牌面样式','牌のスタイル','타일 스타일','टाइल शैली','نمط القطع'],
    'animationIntensity':['Animation intensity','Интенсивность анимации','Intensidad de animación','Intensité des animations','Animationsstärke','Intensidade da animação','Intensità animazioni','Animasyon yoğunluğu','动画强度','アニメーション強度','애니메이션 강도','एनीमेशन तीव्रता','شدة الحركة'],
    'low':['Low','Низкая','Baja','Faible','Niedrig','Baixa','Bassa','Düşük','低','低','낮음','कम','منخفض'],
    'normal':['Normal','Обычная','Normal','Normale','Normal','Normal','Normale','Normal','普通','標準','보통','सामान्य','عادي'],
    'extra':['Extra','Максимальная','Extra','Maximale','Extra','Extra','Extra','Yüksek','增强','高','높음','अधिक','عالٍ'],
    'preferencesNote':['Preferences are stored locally and sync to the cloud when Firebase is configured and the network is available.','Настройки хранятся на устройстве. Облачная синхронизация работает при настроенном Firebase и доступной сети.','Las preferencias se guardan localmente y se sincronizan si Firebase y la red están disponibles.','Les préférences sont enregistrées localement et synchronisées si Firebase et le réseau sont disponibles.','Einstellungen werden lokal gespeichert und bei verfügbarem Firebase und Netzwerk synchronisiert.','As preferências são salvas localmente e sincronizadas se Firebase e rede estiverem disponíveis.','Le preferenze sono salvate localmente e sincronizzate se Firebase e la rete sono disponibili.','Tercihler cihazda saklanır; Firebase ve ağ varsa eşitlenir.','设置保存在本机；配置 Firebase 且网络可用时会同步。','設定は端末に保存され、Firebaseとネットワークが利用可能な場合に同期されます。','설정은 기기에 저장되며 Firebase와 네트워크가 가능하면 동기화됩니다.','सेटिंग्स डिवाइस पर सहेजी जाती हैं और Firebase व नेटवर्क उपलब्ध होने पर सिंक होती हैं。','تُحفظ الإعدادات على الجهاز وتتزامن عند توفر Firebase والشبكة.'],
    'wonTitle':['Puzzle mastered!','Головоломка решена!','¡Puzzle completado!','Puzzle terminé !','Rätsel gemeistert!','Desafio concluído!','Puzzle completato!','Bulmaca tamamlandı!','谜题完成！','パズルクリア！','퍼즐 완료!','पहेली पूरी हुई!','أحسنت حل اللغز!'],
    'wonMessage':['Every pair is matched in','Все пары найдены за','Todas las parejas en','Toutes les paires en','Alle Paare in','Todos os pares em','Tutte le coppie in','Tüm çiftler şu hamlede eşleşti:','所有配对共用了','すべてのペアを揃えました。手数：','모든 짝을 맞췄어요. 이동 횟수:','सभी जोड़ियों को मिलाने में चालें:','تمت مطابقة كل الأزواج في'],
    'movesLower':['moves','ходов','movimientos','coups','Zügen','jogadas','mosse','hamle','步','手','회','चालें','حركة'],
    'nextLevel':['Next level','Следующий уровень','Siguiente nivel','Niveau suivant','Nächstes Level','Próximo nível','Livello successivo','Sonraki seviye','下一关','次のレベル','다음 레벨','अगला स्तर','المستوى التالي'],
    'undo':['Undo last move','Отменить ход','Deshacer movimiento','Annuler le coup','Letzten Zug rückgängig','Desfazer jogada','Annulla mossa','Son hamleyi geri al','撤销上一步','一手戻す','마지막 이동 취소','पिछली चाल वापस लें','تراجع عن الحركة'],
    'hint':['Show an available pair','Показать доступную пару','Mostrar una pareja disponible','Afficher une paire disponible','Verfügbares Paar zeigen','Mostrar um par disponível','Mostra una coppia disponibile','Uygun bir çifti göster','显示可配对的牌','取れるペアを表示','가능한 짝 표시','उपलब्ध जोड़ी दिखाएँ','عرض زوج متاح'],
    'done':['Beautifully done!','Прекрасно!','¡Muy bien!','Magnifique !','Wunderbar!','Muito bem!','Benissimo!','Harika!','太棒了！','すばらしい！','멋져요!','बहुत बढ़िया!','رائع!'],
    'boardHelp':['144 tiles · 4 layers · free left/right edge','144 фишки · 4 слоя · свободный левый или правый край','144 fichas · 4 capas · borde izquierdo/derecho libre','144 tuiles · 4 couches · bord gauche/droit libre','144 Steine · 4 Ebenen · linke/rechte Kante frei','144 peças · 4 camadas · borda esquerda/direita livre','144 tessere · 4 livelli · bordo sinistro/destro libero','144 taş · 4 katman · sol/sağ kenar açık','144张牌 · 4层 · 左右边缘可移除','144枚 · 4層 · 左右端から取れます','타일 144개 · 4층 · 좌우 가장자리 선택 가능','144 टाइलें · 4 परतें · बायाँ/दायाँ किनारा खुला','144 قطعة · 4 طبقات · الحافة اليسرى/اليمنى متاحة'],
    'deselect':['Deselect','Снять выбор','Deseleccionar','Désélectionner','Auswahl aufheben','Desmarcar','Deseleziona','Seçimi kaldır','取消选择','選択解除','선택 해제','चयन हटाएँ','إلغاء التحديد'],
    'shuffle':['Solvable shuffle','Перемешать (решаемая раскладка)','Mezclar solución','Mélange solvable','Lösbar mischen','Embaralhar solução','Mescola soluzione','Çözülebilir şekilde karıştır','重新洗牌（保证可解）','解ける盤面にシャッフル','풀 수 있는 배치로 섞기','हल होने वाला शफल','خلط قابل للحل'],
    'moves':['MOVES','ХОДЫ','MOVIMIENTOS','COUPS','ZÜGE','JOGADAS','MOSSE','HAMLE','步数','手数','이동','चालें','الحركات'],
    'time':['TIME','ВРЕМЯ','TIEMPO','TEMPS','ZEIT','TEMPO','TEMPO','SÜRE','时间','時間','시간','समय','الوقت'],
    'pairs':['PAIRS','ПАРЫ','PAREJAS','PAIRES','PAARE','PARES','COPPIE','ÇİFTLER','配对','ペア','쌍','जोड़े','الأزواج'],
    'chapter':['Chapter','Глава','Capítulo','Chapitre','Kapitel','Capítulo','Capitolo','Bölüm','章节','章','챕터','अध्याय','الفصل'],
    'bestLevels':['Best completed levels on this device','Лучшие пройденные уровни на устройстве','Mejores niveles completados en este dispositivo','Meilleurs niveaux terminés sur cet appareil','Beste abgeschlossene Level auf diesem Gerät','Melhores níveis concluídos neste dispositivo','Migliori livelli completati su questo dispositivo','Bu cihazdaki en iyi tamamlanan seviyeler','本设备已完成的最佳关卡','この端末でクリアした最高レベル','이 기기에서 완료한 최고 레벨','इस डिवाइस पर पूरे किए गए सर्वश्रेष्ठ स्तर','أفضل المستويات المكتملة على هذا الجهاز'],
    'noRecords':['No records yet — finish your first level!','Записей пока нет — пройди первый уровень!','Aún no hay registros: ¡termina tu primer nivel!','Aucun record — termine ton premier niveau !','Noch keine Rekorde — schließe dein erstes Level ab!','Sem registros — conclua seu primeiro nível!','Nessun record — completa il primo livello!','Henüz kayıt yok — ilk seviyeni bitir!','暂无记录——完成第一关吧！','記録はありません。最初のレベルをクリアしよう！','기록이 없어요. 첫 레벨을 완료해 보세요!','अभी कोई रिकॉर्ड नहीं — पहला स्तर पूरा करें!','لا توجد سجلات بعد — أكمل المستوى الأول!'],
    'savedLocal':['Saved on this device; cloud sync is unavailable right now.','Сохранено на устройстве; облачная синхронизация сейчас недоступна.','Guardado en el dispositivo; la sincronización no está disponible.','Enregistré sur cet appareil ; synchronisation indisponible.','Lokal gespeichert; Cloud-Synchronisierung derzeit nicht verfügbar.','Salvo no dispositivo; sincronização indisponível agora.','Salvato sul dispositivo; sincronizzazione cloud non disponibile.','Cihaza kaydedildi; bulut eşitlemesi şu an kullanılamıyor.','已保存在本机；云同步暂不可用。','端末に保存しました。クラウド同期は現在利用できません。','기기에 저장됨. 클라우드 동기화는 현재 사용할 수 없어요.','डिवाइस पर सहेजा गया; क्लाउड सिंक अभी उपलब्ध नहीं।','حُفظ على الجهاز؛ المزامنة السحابية غير متاحة الآن.'],
    'dailyPlanned':['Daily challenges are planned for a future update.','Ежедневные испытания появятся в будущем обновлении.','Los retos diarios llegarán en una futura actualización.','Les défis quotidiens arriveront dans une prochaine mise à jour.','Tägliche Herausforderungen folgen in einem zukünftigen Update.','Desafios diários chegarão numa atualização futura.','Le sfide giornaliere arriveranno in un futuro aggiornamento.','Günlük görevler gelecek güncellemede eklenecek.','每日挑战将在未来版本推出。','デイリーチャレンジは今後の更新で追加予定です。','일일 도전은 향후 업데이트에서 제공됩니다.','दैनिक चुनौतियाँ भविष्य के अपडेट में आएँगी।','ستتوفر التحديات اليومية في تحديث قادم.'],
    'dailyDone':['Today’s challenge is complete. Come back tomorrow!','Сегодняшнее испытание уже пройдено. Возвращайся завтра!','¡Reto de hoy completado! Vuelve mañana.','Défi du jour terminé ! Reviens demain.','Tagesrätsel geschafft! Komm morgen wieder.','Desafio de hoje concluído! Volte amanhã.','Sfida di oggi completata! Torna domani.','Bugünün görevi tamamlandı. Yarın tekrar gel!','今日挑战已完成，明天再来！','今日のチャレンジは完了！また明日。','오늘의 도전을 완료했어요. 내일 다시 만나요!','आज की चुनौती पूरी हुई। कल फिर आएँ!','اكتمل تحدي اليوم. عد غدًا!'],
    'multiplayerPlanned':['Online multiplayer is planned; no live matches yet.','Сетевая игра планируется; онлайн-матчей пока нет.','El multijugador está planeado; aún no hay partidas en vivo.','Le multijoueur est prévu ; aucune partie en direct pour le moment.','Mehrspieler ist geplant; noch keine Live-Partien.','O modo multijogador está planejado; ainda não há partidas.','Il multigiocatore è previsto; non ci sono ancora partite online.','Çok oyunculu mod planlanıyor; henüz canlı maç yok.','多人模式正在规划中，暂时没有在线对局。','オンライン対戦は今後対応予定です。','온라인 멀티플레이는 준비 중이며 아직 실시간 경기는 없습니다.','मल्टीप्लेयर की योजना है; अभी लाइव मैच नहीं हैं।','اللعب الجماعي قيد التخطيط؛ لا توجد مباريات مباشرة بعد.'],
  };
  final values = t[key];
  if (values == null) return key;
  const codes = ['en','ru','es','fr','de','pt','it','tr','zh','ja','ko','hi','ar'];
  final index = codes.indexOf(language);
  return values[index < 0 ? 0 : index];
}

const pine = Color(0xFF244E42);
const leaf = Color(0xFF6F9E78);
const cream = Color(0xFFFFF7E8);
const peach = Color(0xFFF2B58E);
const ink = Color(0xFF263B32);

class FitaMahjongApp extends StatelessWidget {
  const FitaMahjongApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'FITA Majong',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: cream,
          colorScheme: ColorScheme.fromSeed(seedColor: pine, brightness: Brightness.light),
          fontFamily: 'Roboto',
        ),
        home: const WelcomeScreen(),
      );
}

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  bool _busy = false;
  String language = 'en';
  @override
  void initState() { super.initState(); SharedPreferences.getInstance().then((p) { if (mounted) setState(() => language = p.getString('fita.language') ?? 'en'); }); }
  Future<void> _setLanguage(String value) async { final p = await SharedPreferences.getInstance(); await p.setString('fita.language', value); if (mounted) setState(() => language = value); }

  Future<void> _showLanguagePicker() async {
    const languages = <(String, String, String)>[
      ('en', '🇬🇧', 'English'), ('ru', '🇷🇺', 'Русский'),
      ('es', '🇪🇸', 'Español'), ('fr', '🇫🇷', 'Français'),
      ('de', '🇩🇪', 'Deutsch'), ('pt', '🇵🇹', 'Português'),
      ('it', '🇮🇹', 'Italiano'), ('tr', '🇹🇷', 'Türkçe'),
      ('zh', '🇨🇳', '中文'), ('ja', '🇯🇵', '日本語'),
      ('ko', '🇰🇷', '한국어'), ('hi', '🇮🇳', 'हिन्दी'),
      ('ar', '🇸🇦', 'العربية'),
    ];
    final chosen = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: const Color(0xFFFFF8EC),
      isScrollControlled: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Choose your language', style: TextStyle(fontSize: 23, fontWeight: FontWeight.w900, color: pine)),
            const SizedBox(height: 5),
            Text('Выберите язык · 13 languages available', style: TextStyle(fontSize: 12, color: pine.withValues(alpha: .68))),
            const SizedBox(height: 16),
            Flexible(child: GridView.builder(
              shrinkWrap: true,
              itemCount: languages.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 9, crossAxisSpacing: 9, childAspectRatio: 2.45),
              itemBuilder: (context, index) {
                final item = languages[index];
                final selectedLanguage = item.$1 == language;
                return Material(
                  color: selectedLanguage ? const Color(0xFFDDEBDD) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => Navigator.of(sheetContext).pop(item.$1),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), border: Border.all(color: selectedLanguage ? leaf : const Color(0xFFE8E2D6), width: selectedLanguage ? 2 : 1)),
                      child: Row(children: [
                        Text(item.$2, style: const TextStyle(fontSize: 22)),
                        const SizedBox(width: 8),
                        Expanded(child: Text(item.$3, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: pine, fontSize: 12, fontWeight: FontWeight.w800))),
                        if (selectedLanguage) const Icon(Icons.check_circle_rounded, color: leaf, size: 17),
                      ]),
                    ),
                  ),
                );
              },
            )),
          ]),
        ),
      ),
    );
    if (chosen != null) await _setLanguage(chosen);
  }

  Future<void> _continueAsGuest() async {
    setState(() => _busy = true);
    try {
      await AuthService.instance.continueAsGuest();
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => HomeScreen(initialLanguage: language)),
      );
    } catch (error) {
      _notice('${_tr(language, 'guestError')}: $error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _notice(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Stack(
          children: [
            const Positioned.fill(child: NatureBackdrop()),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 18, 24, 22),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 46, height: 46,
                          decoration: BoxDecoration(color: Colors.white.withValues(alpha: .82), borderRadius: BorderRadius.circular(16)),
                          child: const Icon(Icons.spa_rounded, color: pine, size: 28),
                        ),
                        const SizedBox(width: 12),
                        const Text('FITA', style: TextStyle(fontSize: 19, letterSpacing: 4, fontWeight: FontWeight.w900, color: pine)),
                        const Spacer(),
                        Material(color: Colors.white.withValues(alpha: .88), borderRadius: BorderRadius.circular(16), child: InkWell(borderRadius: BorderRadius.circular(16), onTap: _showLanguagePicker, child: Padding(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9), child: Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.language_rounded, color: pine, size: 18), const SizedBox(width: 6), Text(language.toUpperCase(), style: const TextStyle(color: pine, fontSize: 12, fontWeight: FontWeight.w900)), const SizedBox(width: 4), const Icon(Icons.keyboard_arrow_down_rounded, color: pine, size: 18)])))),
                      ],
                    ),
                    const Spacer(flex: 2),
                    const Icon(Icons.wb_twilight_rounded, size: 44, color: Color(0xFFD58D59)),
                    const SizedBox(height: 12),
                    Text(_tr(language, 'welcomeTitle'), textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 34, height: 1.12, fontWeight: FontWeight.w900, color: pine, letterSpacing: -.8)),
                    const SizedBox(height: 12),
                    Text(_tr(language, 'welcomeSubtitle'), textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 15, color: pine.withValues(alpha: .78))),
                    const Spacer(flex: 2),
                    _TileShowcase(),
                    const SizedBox(height: 28),
                    SizedBox(width: double.infinity, height: 56,
                      child: FilledButton(
                        style: FilledButton.styleFrom(backgroundColor: pine, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
                        onPressed: _busy ? null : _continueAsGuest,
                        child: Text(_tr(language, _busy ? 'pleaseWait' : 'play'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                      )),
                    const SizedBox(height: 10),
                    Text(_tr(language, 'guestNote'), style: TextStyle(fontSize: 11, color: pine.withValues(alpha: .7))),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
}

class HomeScreen extends StatefulWidget {
  final String initialLanguage;
  const HomeScreen({super.key, this.initialLanguage = 'en'});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AudioPlayer _musicPlayer = AudioPlayer();
  Timer? _musicFadeTimer;
  bool musicEnabled = true;
  double _musicVolume = 0;
  bool _musicReady = false;

  Uint8List _buildAmbientMusic() {
    const rate = 22050;
    const duration = 12.0;
    final count = (rate * duration).round();
    final bytes = Uint8List(44 + count * 2);
    final h = ByteData.sublistView(bytes);
    void tag(int offset, String value) {
      for (var i = 0; i < value.length; i++) { bytes[offset + i] = value.codeUnitAt(i); }
    }
    tag(0, 'RIFF'); h.setUint32(4, bytes.length - 8, Endian.little);
    tag(8, 'WAVE'); tag(12, 'fmt '); h.setUint32(16, 16, Endian.little);
    h.setUint16(20, 1, Endian.little); h.setUint16(22, 1, Endian.little);
    h.setUint32(24, rate, Endian.little); h.setUint32(28, rate * 2, Endian.little);
    h.setUint16(32, 2, Endian.little); h.setUint16(34, 16, Endian.little);
    tag(36, 'data'); h.setUint32(40, count * 2, Endian.little);
    const notes = <double>[130.81, 164.81, 196.00, 261.63, 329.63];
    for (var i = 0; i < count; i++) {
      final t = i / rate;
      final edge = (min(t, duration - t) / 1.2).clamp(0.0, 1.0).toDouble();
      final fade = edge * edge * (3 - 2 * edge);
      var sample = 0.0;
      for (var n = 0; n < notes.length; n++) {
        final wobble = 1 + .0015 * sin(2 * pi * .08 * t + n);
        final tone = sin(2 * pi * notes[n] * wobble * t);
        final overtone = sin(2 * pi * notes[n] * 2 * wobble * t) * .12;
        sample += (tone + overtone) * (n < 3 ? .16 : .07);
      }
      sample *= fade * (.72 + .08 * sin(2 * pi * .17 * t));
      h.setInt16(44 + i * 2, (sample * 4200).round().clamp(-32768, 32767), Endian.little);
    }
    return bytes;
  }

  Future<void> _startMusic() async {
    try {
      await _musicPlayer.setReleaseMode(ReleaseMode.loop);
      await _musicPlayer.setVolume(0);
      await _musicPlayer.play(BytesSource(_buildAmbientMusic()), volume: 0);
      _musicReady = true;
      _fadeMusicTo(musicEnabled ? .22 : 0);
      if (!musicEnabled) await _musicPlayer.pause();
    } catch (_) {
      // Ambient music is optional; game play must never depend on audio.
    }
  }

  void _fadeMusicTo(double target) {
    _musicFadeTimer?.cancel();
    const steps = 16;
    var step = 0;
    final start = _musicVolume;
    _musicFadeTimer = Timer.periodic(const Duration(milliseconds: 45), (timer) {
      step++;
      final p = (step / steps).clamp(0.0, 1.0).toDouble();
      final eased = p * p * (3 - 2 * p);
      _musicVolume = start + (target - start) * eased;
      unawaited(_musicPlayer.setVolume(_musicVolume));
      if (step >= steps) timer.cancel();
    });
  }

  Future<void> _setMusicEnabled(bool enabled) async {
    setState(() => musicEnabled = enabled);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('fita.music.enabled', enabled);
    if (!_musicReady) {
      if (enabled) await _startMusic();
      return;
    }
    if (enabled) {
      await _musicPlayer.resume();
      _fadeMusicTo(.22);
    } else {
      _fadeMusicTo(0);
      Future<void>.delayed(const Duration(milliseconds: 800), () {
        if (mounted && !musicEnabled) unawaited(_musicPlayer.pause());
      });
    }
  }

  int level = 1;
  bool sound = true;
  bool haptics = true;
  bool comboEffects = true;
  int backgroundTheme = 0;
  int tileTheme = 0;
  int animationLevel = 2;
  bool dailyCompleted = false;
  int dailyStreak = 0;
  int playerXp = 0;
  int playerLifetimeXp = 0;
  String language = 'en';

  @override
  void initState() {
    super.initState();
    _restoreProgress();
    _restoreMusic();
  }

  Future<void> _restoreMusic() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    musicEnabled = prefs.getBool('fita.music.enabled') ?? true;
    if (musicEnabled) await _startMusic();
    if (mounted) setState(() {});
  }

  Future<void> _restoreProgress() async {
    final saved = await ProgressStore.instance.load();
    if (!mounted) return;
    setState(() {
      level = (saved['level'] as num?)?.toInt() ?? 1;
      sound = saved['sound'] as bool? ?? true;
      haptics = saved['haptics'] as bool? ?? true;
    });
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      backgroundTheme = prefs.getInt('fita.theme.background') ?? 0;
      tileTheme = prefs.getInt('fita.theme.tiles') ?? 0;
      animationLevel = prefs.getInt('fita.animation.level') ?? 2;
      comboEffects = prefs.getBool('fita.combo.effects') ?? true;
      language = prefs.getString('fita.language') ?? widget.initialLanguage;
      dailyCompleted = prefs.getString('fita.daily.completed') == _todayKey();
      dailyStreak = prefs.getInt('fita.daily.streak') ?? 0;
      playerXp = prefs.getInt('fita.rewards.xp') ?? 0;
      playerLifetimeXp = prefs.getInt('fita.rewards.totalXp') ?? (prefs.getInt('fita.rewards.xp') ?? 0);
    });
  }

  int get _playerRankLevel => playerLifetimeXp ~/ 100 + 1;

  String _playerRank(int rankLevel) {
    if (rankLevel >= 50) return language == 'ru' ? 'Нефритовый мастер' : 'Jade Master';
    if (rankLevel >= 30) return language == 'ru' ? 'Хранитель сада' : 'Garden Guardian';
    if (rankLevel >= 20) return language == 'ru' ? 'Золотой феникс' : 'Golden Phoenix';
    if (rankLevel >= 10) return language == 'ru' ? 'Серебряный лист' : 'Silver Leaf';
    if (rankLevel >= 5) return language == 'ru' ? 'Путник леса' : 'Forest Wanderer';
    return language == 'ru' ? 'Росток' : 'Sprout';
  }

  Future<void> _refreshPlayerXp() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      playerXp = prefs.getInt('fita.rewards.xp') ?? 0;
      playerLifetimeXp = prefs.getInt('fita.rewards.totalXp') ?? (prefs.getInt('fita.rewards.xp') ?? 0);
    });
  }

  Future<void> _saveProgress() async {
    try {
      await ProgressStore.instance.save(
        level: level,
        sound: sound,
        haptics: haptics,
      );
    } catch (error) {
      if (mounted) _message(context, _tr(language, 'savedLocal'));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Stack(children: [
      Positioned.fill(child: NatureBackdrop(theme: backgroundTheme)),
      SafeArea(child: CustomScrollView(slivers: [
        SliverPadding(padding: const EdgeInsets.fromLTRB(20, 16, 20, 28), sliver: SliverList(delegate: SliverChildListDelegate([
          Row(children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(_tr(language, 'goodDay'), style: const TextStyle(fontSize: 10, letterSpacing: 2, color: pine, fontWeight: FontWeight.w800)),
              SizedBox(height: 5),
              Text(_tr(language, 'quietCorner'), style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w900, color: pine)),
            ]),
            const Spacer(),
            IconButton.filledTonal(onPressed: () => _settings(context), icon: const Icon(Icons.tune_rounded), style: IconButton.styleFrom(backgroundColor: Colors.white.withValues(alpha: .75), foregroundColor: pine)),
          ]),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .9),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0xFFD9C08A).withValues(alpha: .75)),
              boxShadow: [BoxShadow(color: pine.withValues(alpha: .07), blurRadius: 16, offset: const Offset(0, 5))],
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(
                  width: 48, height: 48,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(colors: [Color(0xFFFFE4A8), Color(0xFFD58D59)]),
                  ),
                  child: const Icon(Icons.workspace_premium_rounded, color: Color(0xFF315B45), size: 28),
                ),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(language == 'ru' ? 'УРОВЕНЬ ИГРОКА $_playerRankLevel' : 'PLAYER LEVEL $_playerRankLevel', style: const TextStyle(color: pine, fontSize: 10, letterSpacing: 1.4, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 3),
                  Text(_playerRank(_playerRankLevel), style: const TextStyle(color: pine, fontSize: 17, fontWeight: FontWeight.w900)),
                ])),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  const Icon(Icons.stars_rounded, color: Color(0xFFD58D59), size: 20),
                  Text('$playerXp XP', style: const TextStyle(color: pine, fontSize: 13, fontWeight: FontWeight.w900)),
                ]),
              ]),
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: TweenAnimationBuilder<double>(
                  key: ValueKey('xp-$playerLifetimeXp'),
                  tween: Tween(begin: 0, end: (playerLifetimeXp % 100) / 100),
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeOutCubic,
                  builder: (context, progress, child) => LinearProgressIndicator(
                    value: progress.clamp(0.0, 1.0).toDouble(),
                    minHeight: 10,
                    backgroundColor: const Color(0xFFE6E9DD),
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFD58D59)),
                  ),
                ),
              ),
              const SizedBox(height: 7),
              Row(children: [
                Expanded(child: Text(language == 'ru' ? 'До следующего уровня' : 'Progress to next level', style: const TextStyle(color: Colors.black54, fontSize: 11))),
                Text('${playerLifetimeXp % 100}/100 XP', style: const TextStyle(color: pine, fontSize: 11, fontWeight: FontWeight.w800)),
              ]),
            ]),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF47765D), Color(0xFF8AA77B)], begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(28), boxShadow: [BoxShadow(color: pine.withValues(alpha: .16), blurRadius: 24, offset: const Offset(0, 12))]),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(_tr(language, 'gardenPath'), style: const TextStyle(color: Color(0xFFDDEACB), fontSize: 10, letterSpacing: 2, fontWeight: FontWeight.w800)),
                  SizedBox(height: 8),
                  Text(_tr(language, 'freshPuzzle'), style: const TextStyle(color: Colors.white, fontSize: 25, height: 1.12, fontWeight: FontWeight.w900)),
                ])),
                Container(width: 88, height: 100, decoration: BoxDecoration(color: Colors.white.withValues(alpha: .16), borderRadius: BorderRadius.circular(24)), child: const Icon(Icons.park_rounded, color: Color(0xFFFFE4A8), size: 62)),
              ]),
              const SizedBox(height: 18),
              SizedBox(width: double.infinity, height: 48, child: FilledButton(
                style: FilledButton.styleFrom(backgroundColor: cream, foregroundColor: pine, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                onPressed: () => _launchLevel(level),
                child: Text('${_tr(language, 'continue')}  ·  ${_tr(language, 'level')} $level', style: const TextStyle(fontWeight: FontWeight.w900)),
              )),
            ]),
          ),
          const SizedBox(height: 24),
          Row(children: [Expanded(child: Text(_tr(language, 'yourJourney'), style: const TextStyle(fontSize: 11, letterSpacing: 2, color: pine, fontWeight: FontWeight.w900))), Text('${_tr(language, 'level')} $level / 10,000', style: const TextStyle(fontSize: 10, letterSpacing: 1, color: pine, fontWeight: FontWeight.w800))]),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _ModeCard(icon: Icons.auto_awesome_rounded, title: _tr(language, 'dailyDew'), subtitle: _dailySubtitle(), color: const Color(0xFFF7D6A8), onTap: _launchDailyLevel)),
            const SizedBox(width: 12),
            Expanded(child: _ModeCard(icon: Icons.emoji_events_rounded, title: _tr(language, 'trailRanks'), subtitle: _tr(language, 'climbLeaderboard'), color: const Color(0xFFC8DCC1), onTap: _showLeaderboard)),
          ]),
          const SizedBox(height: 12),
          _WideAction(icon: Icons.people_alt_rounded, title: _tr(language, 'playFriend'), subtitle: _tr(language, 'sameLayout'), onTap: _openMultiplayer),
          const SizedBox(height: 12),
          _WideAction(icon: Icons.workspace_premium_rounded, title: language == 'ru' ? 'Достижения' : 'Achievements', subtitle: language == 'ru' ? 'Открывай значки за свои победы' : 'Unlock badges as you play', onTap: _showAchievements),
          const SizedBox(height: 12),
          _WideAction(icon: Icons.map_rounded, title: _tr(language, 'levelPath'), subtitle: _tr(language, 'chapters'), onTap: _showLevelPath),
          const SizedBox(height: 12),
          _WideAction(icon: Icons.shopping_bag_rounded, title: language == 'ru' ? 'Магазин тем' : 'Theme shop', subtitle: language == 'ru' ? 'Открывай фоны и стили за XP' : 'Unlock backgrounds and tile styles with XP', onTap: _showThemeShop),
          const SizedBox(height: 18),
          Center(child: Text(_tr(language, 'breathe'), style: TextStyle(color: pine.withValues(alpha: .7), fontStyle: FontStyle.italic))),
        ]))),
      ])),
    ]),
  );

  String _todayKey() {
    final now = DateTime.now().toUtc();
    return '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  int _dailySeed() {
    var seed = 17;
    for (final unit in _todayKey().codeUnits) {
      seed = (seed * 31 + unit) & 0x7fffffff;
    }
    return seed;
  }

  String _dailySubtitle() {
    final status = dailyCompleted
        ? '✓ ${_tr(language, 'completed')}'
        : _tr(language, 'dailyChallenge');
    return dailyStreak > 0 ? '$status  ·  🔥 $dailyStreak' : status;
  }

  Future<void> _launchDailyLevel() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _todayKey();
    if (!mounted) return;
    final alreadyDone = dailyCompleted || prefs.getString('fita.daily.completed') == today;
    if (alreadyDone) {
      _message(context, _tr(language, 'dailyDone'));
      return;
    }
    final won = await Navigator.of(context).push<bool>(MaterialPageRoute(builder: (_) => GameScreen(
      level: _dailySeed() % 10000 + 1,
      seed: _dailySeed(),
      dailyDate: today,
      sound: sound,
      haptics: haptics,
      backgroundTheme: backgroundTheme,
      tileTheme: tileTheme,
      animationLevel: animationLevel,
      comboEffects: comboEffects,
      language: language,
    )));
    if (won == true) {
      final completedDailyCount = (prefs.getInt('fita.stats.dailyWins') ?? 0) + 1;
      await prefs.setInt('fita.stats.dailyWins', completedDailyCount);
      final now = DateTime.now().toUtc();
      final yesterday = now.subtract(const Duration(days: 1));
      final yesterdayKey =
          '${yesterday.year.toString().padLeft(4, '0')}-${yesterday.month.toString().padLeft(2, '0')}-${yesterday.day.toString().padLeft(2, '0')}';
      final lastCompleted = prefs.getString('fita.daily.lastCompleted');
      final previousStreak = prefs.getInt('fita.daily.streak') ?? 0;
      final nextStreak = lastCompleted == today
          ? previousStreak
          : lastCompleted == yesterdayKey
              ? previousStreak + 1
              : 1;
      await prefs.setString('fita.daily.completed', today);
      await prefs.setString('fita.daily.lastCompleted', today);
      await prefs.setInt('fita.daily.streak', nextStreak);
      if (mounted) {
        setState(() {
          dailyCompleted = true;
          dailyStreak = nextStreak;
        });
      }
    }
  }

  Future<void> _openMultiplayer() async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: cream,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) => _MultiplayerLobby(
        language: language,
        onRoomReady: (room) async {
          Navigator.of(sheetContext).pop();
          await _launchMultiplayer(room);
        },
      ),
    );
  }

  Future<void> _launchMultiplayer(MultiplayerRoom room) async {
    await Navigator.of(context).push<bool>(MaterialPageRoute(builder: (_) => GameScreen(
      level: room.seed % 10000 + 1,
      seed: room.seed,
      roomCode: room.code,
      playerUid: room.playerUid,
      sound: sound,
      haptics: haptics,
      backgroundTheme: backgroundTheme,
      tileTheme: tileTheme,
      animationLevel: animationLevel,
      comboEffects: comboEffects,
      language: language,
    )));
  }

  Future<void> _launchLevel(int selectedLevel) async {
    final won = await Navigator.of(context).push<bool>(MaterialPageRoute(builder: (_) => GameScreen(
      level: selectedLevel,
      sound: sound,
      haptics: haptics,
      backgroundTheme: backgroundTheme,
      tileTheme: tileTheme,
      animationLevel: animationLevel,
      comboEffects: comboEffects,
      language: language,
    )));
    await _refreshPlayerXp();
    if (won == true && mounted && selectedLevel == level) {
      setState(() => level = level >= 10000 ? 10000 : level + 1);
      await _saveProgress();
    }
  }

  void _showLevelPath() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: cream,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) => SafeArea(
        child: SizedBox(
          height: MediaQuery.of(sheetContext).size.height * .72,
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 8, 22, 12),
              child: Align(alignment: Alignment.centerLeft, child: Text('🌿 ${_tr(language, 'levelPath')}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: pine))),
            ),
            Expanded(child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 10,
              itemBuilder: (ctx, index) {
                final chapter = index + 1;
                final firstLevel = index * 1000 + 1;
                final unlocked = firstLevel <= level;
                final completed = level > (index + 1) * 1000;
                return Card(
                  color: unlocked ? Colors.white : const Color(0xFFE9E5DC),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: completed ? const Color(0xFFB8F2E6) : unlocked ? const Color(0xFFFFE4B5) : Colors.black12,
                      child: Icon(completed ? Icons.check_rounded : unlocked ? Icons.flag_rounded : Icons.lock_rounded, color: pine),
                    ),
                    title: Text('${_tr(language, 'chapter')} $chapter', style: const TextStyle(fontWeight: FontWeight.w800, color: pine)),
                    subtitle: Text('${_tr(language, 'levels')} $firstLevel–${(index + 1) * 1000}'),
                    trailing: unlocked ? const Icon(Icons.chevron_right_rounded, color: pine) : null,
                    onTap: unlocked ? () {
                      Navigator.of(sheetContext).pop();
                      _launchLevel(firstLevel);
                    } : null,
                  ),
                );
              },
            )),
          ]),
        ),
      ),
    );
  }

  Future<void> _showAchievements() async {
    final prefs = await SharedPreferences.getInstance();
    final wins = prefs.getInt('fita.stats.wins') ?? 0;
    final dailyWins = prefs.getInt('fita.stats.dailyWins') ?? 0;
    final highestLevel = prefs.getInt('fita.stats.highestLevel') ?? level;
    final bestCombo = prefs.getInt('fita.combo.bestStreak') ?? 0;
    final streak = prefs.getInt('fita.daily.streak') ?? 0;
    final isRu = language == 'ru';
    final achievements = <({String title, String description, IconData icon, int value, int goal})>[
      (title: isRu ? 'Первый шаг' : 'First steps', description: isRu ? 'Заверши первую партию' : 'Win your first game', icon: Icons.flag_rounded, value: wins, goal: 1),
      (title: isRu ? 'Мастер головоломок' : 'Puzzle master', description: isRu ? 'Победи в 10 партиях' : 'Win 10 games', icon: Icons.auto_awesome_rounded, value: wins, goal: 10),
      (title: isRu ? 'Легенда сада' : 'Garden legend', description: isRu ? 'Победи в 50 партиях' : 'Win 50 games', icon: Icons.park_rounded, value: wins, goal: 50),
      (title: isRu ? 'Путь открыт' : 'Pathfinder', description: isRu ? 'Достигни 10-го уровня' : 'Reach level 10', icon: Icons.route_rounded, value: highestLevel, goal: 10),
      (title: isRu ? 'Вершина пути' : 'Trailblazer', description: isRu ? 'Достигни 100-го уровня' : 'Reach level 100', icon: Icons.military_tech_rounded, value: highestLevel, goal: 100),
      (title: isRu ? 'Роса дня' : 'Daily dew', description: isRu ? 'Пройди ежедневный уровень' : 'Complete a daily level', icon: Icons.wb_twilight_rounded, value: dailyWins, goal: 1),
      (title: isRu ? 'Ритм недели' : 'Weekly rhythm', description: isRu ? 'Играй 3 дня подряд' : 'Play daily 3 days in a row', icon: Icons.local_fire_department_rounded, value: streak, goal: 3),
      (title: isRu ? 'Неудержимый' : 'Unstoppable', description: isRu ? 'Играй 7 дней подряд' : 'Keep a 7-day streak', icon: Icons.bolt_rounded, value: streak, goal: 7),
      (title: isRu ? 'Комбо x5' : 'Combo x5', description: isRu ? 'Найди 5 пар подряд' : 'Match 5 pairs in a row', icon: Icons.flash_on_rounded, value: bestCombo, goal: 5),
      (title: isRu ? 'Комбо x10' : 'Combo x10', description: isRu ? 'Найди 10 пар подряд' : 'Match 10 pairs in a row', icon: Icons.local_fire_department_rounded, value: bestCombo, goal: 10),
    ];
    if (!mounted) return;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: cream,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                const Icon(Icons.workspace_premium_rounded, color: Color(0xFFD58D59), size: 30),
                const SizedBox(width: 8),
                Expanded(child: Text(isRu ? '🏅 Достижения' : '🏅 Achievements', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: pine))),
              ]),
              const SizedBox(height: 6),
              Text(isRu ? 'Открыто: ${achievements.where((a) => a.value >= a.goal).length} из ${achievements.length}' : 'Unlocked: ${achievements.where((a) => a.value >= a.goal).length} of ${achievements.length}', style: const TextStyle(color: Colors.black54)),
              const SizedBox(height: 4),
              FutureBuilder<SharedPreferences>(
                future: SharedPreferences.getInstance(),
                builder: (context, snapshot) {
                  final xp = snapshot.data?.getInt('fita.rewards.xp') ?? 0;
                  return Row(children: [
                    const Icon(Icons.stars_rounded, color: Color(0xFFD58D59), size: 20),
                    const SizedBox(width: 5),
                    Text('XP $xp', style: const TextStyle(color: pine, fontWeight: FontWeight.w900)),
                    const SizedBox(width: 8),
                    Text(isRu ? 'Награды за достижения' : 'Achievement rewards', style: const TextStyle(color: Colors.black54, fontSize: 12)),
                  ]);
                },
              ),
              const SizedBox(height: 12),
              Flexible(child: ListView.separated(
                shrinkWrap: true,
                itemCount: achievements.length,
                separatorBuilder: (_, __) => const SizedBox(height: 4),
                itemBuilder: (context, index) {
                  final a = achievements[index];
                  final unlocked = a.value >= a.goal;
                  return TweenAnimationBuilder<double>(
                    key: ValueKey('achievement-${index}'),
                    tween: Tween(begin: 0, end: 1),
                    duration: Duration(milliseconds: 280 + index * 45),
                    curve: Curves.easeOutBack,
                    builder: (context, progress, child) => Opacity(
                      opacity: progress.clamp(0.0, 1.0).toDouble(),
                      child: Transform.translate(offset: Offset(0, 12 * (1 - progress)), child: child),
                    ),
                    child: ListTile(
                      leading: AnimatedContainer(
                        duration: const Duration(milliseconds: 350),
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: unlocked ? const Color(0xFFFFE4B5) : Colors.black12,
                          boxShadow: unlocked ? const [BoxShadow(color: Color(0x44D58D59), blurRadius: 10, spreadRadius: 1)] : const [],
                        ),
                        child: Icon(unlocked ? Icons.check_rounded : a.icon, color: unlocked ? pine : Colors.black45),
                      ),
                      title: Text(a.title, style: TextStyle(color: unlocked ? pine : Colors.black54, fontWeight: FontWeight.w800)),
                      subtitle: Text(a.description),
                      trailing: SizedBox(
                        width: 68,
                        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.end, children: [
                          Text('${a.value.clamp(0, a.goal)}/${a.goal}', textAlign: TextAlign.end, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: pine)),
                          Text(unlocked ? '+XP' : '＋XP', style: TextStyle(fontSize: 10, color: unlocked ? const Color(0xFFD58D59) : Colors.black38, fontWeight: FontWeight.w900)),
                        ]),
                      ),
                    ),
                  );
                },
              )),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showLeaderboard() async {
    final prefs = await SharedPreferences.getInstance();
    final scores = prefs.getStringList('fita.leaderboard') ?? <String>[];
    if (!mounted) return;
    showModalBottomSheet<void>(context: context, backgroundColor: cream, showDragHandle: true, builder: (ctx) => Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('🏆 ${_tr(language, 'trailRanks')}', style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w900, color: pine)),
        const SizedBox(height: 8),
        Text(_tr(language, 'bestLevels'), style: const TextStyle(color: Colors.black54)),
        const SizedBox(height: 12),
        if (scores.isEmpty) Padding(padding: const EdgeInsets.all(18), child: Text(_tr(language, 'noRecords'))),
        ...scores.take(10).toList().asMap().entries.map((e) => ListTile(leading: CircleAvatar(backgroundColor: const Color(0xFFFFE4B5), child: Text('${e.key + 1}')), title: Text(e.value.split('|').first), subtitle: Text(e.value.contains('|') ? '${_tr(language, 'level')} ${e.value.split('|').last}' : _tr(language, 'completed')), dense: true)),
      ]),
    ));
  }

  Future<void> _showThemeShop() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('fita.rewards.totalXp')) {
      await prefs.setInt('fita.rewards.totalXp', prefs.getInt('fita.rewards.xp') ?? 0);
    }
    final ownedBackgrounds = prefs.getStringList('fita.shop.owned.background') ?? <String>['0'];
    final ownedTiles = prefs.getStringList('fita.shop.owned.tiles') ?? <String>['0'];
    final previousBackground = prefs.getInt('fita.theme.background') ?? backgroundTheme;
    final previousTiles = prefs.getInt('fita.theme.tiles') ?? tileTheme;
    if (!ownedBackgrounds.contains('$previousBackground')) ownedBackgrounds.add('$previousBackground');
    if (!ownedTiles.contains('$previousTiles')) ownedTiles.add('$previousTiles');
    await prefs.setStringList('fita.shop.owned.background', ownedBackgrounds);
    await prefs.setStringList('fita.shop.owned.tiles', ownedTiles);
    if (!mounted) return;
    setState(() => playerXp = prefs.getInt('fita.rewards.xp') ?? playerXp);
    const costs = [0, 100, 250, 500];
    const backgroundNames = ['Classic Garden', 'Rose Sunset', 'Crystal Lagoon', 'Midnight Aurora'];
    const tileNames = ['Garden', 'Rainbow', 'Crystal', 'Starlight'];
    const backgroundNamesRu = ['Классический сад', 'Розовый закат', 'Хрустальная лагуна', 'Полярное сияние'];
    const tileNamesRu = ['Сад', 'Радуга', 'Кристалл', 'Звёздный свет'];
    const backgroundGradients = [
      [Color(0xFFE8F0DE), Color(0xFFFFF6E7)],
      [Color(0xFFFFD6E8), Color(0xFFFFE7A8)],
      [Color(0xFFB8F2E6), Color(0xFFCDB4DB)],
      [Color(0xFF171B45), Color(0xFF302B63)],
    ];
    const tileColors = [Color(0xFFFFFDF6), Color(0xFFFFD6E8), Color(0xFFB8F2E6), Color(0xFF22254B)];
    const tileSymbols = ['🌿', '🌈', '💎', '✨'];
    var previewBackground = backgroundTheme.clamp(0, 3).toInt();
    var previewTiles = tileTheme.clamp(0, 3).toInt();
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: cream,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) => StatefulBuilder(builder: (sheetContext, setSheet) {
        var xp = prefs.getInt('fita.rewards.xp') ?? playerXp;
        final backgrounds = prefs.getStringList('fita.shop.owned.background') ?? <String>['0'];
        final tiles = prefs.getStringList('fita.shop.owned.tiles') ?? <String>['0'];
        Future<void> buy(String type, int index) async {
          final owned = type == 'background' ? backgrounds : tiles;
          if (owned.contains('$index')) {
            if (type == 'background') {
              await prefs.setInt('fita.theme.background', index);
              if (mounted) setState(() => backgroundTheme = index);
            } else {
              await prefs.setInt('fita.theme.tiles', index);
              if (mounted) setState(() => tileTheme = index);
            }
            setSheet(() {});
            return;
          }
          final price = costs[index];
          if (xp < price) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(language == 'ru' ? 'Не хватает XP: нужно ещё ${price - xp}' : 'Not enough XP: ${price - xp} more needed')));
            return;
          }
          xp -= price;
          await prefs.setInt('fita.rewards.xp', xp);
          owned.add('$index');
          await prefs.setStringList(type == 'background' ? 'fita.shop.owned.background' : 'fita.shop.owned.tiles', owned);
          if (type == 'background') {
            await prefs.setInt('fita.theme.background', index);
            if (mounted) setState(() { backgroundTheme = index; playerXp = xp; });
          } else {
            await prefs.setInt('fita.theme.tiles', index);
            if (mounted) setState(() { tileTheme = index; playerXp = xp; });
          }
          setSheet(() {});
        }
        Widget themeCard({required String type, required int index}) {
          final owned = (type == 'background' ? backgrounds : tiles).contains('$index');
          final active = type == 'background' ? backgroundTheme == index : tileTheme == index;
          final name = type == 'background'
              ? (language == 'ru' ? backgroundNamesRu[index] : backgroundNames[index])
              : (language == 'ru' ? tileNamesRu[index] : tileNames[index]);
          final previewed = type == 'background' ? previewBackground == index : previewTiles == index;
          return InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => setSheet(() { if (type == 'background') { previewBackground = index; } else { previewTiles = index; } }),
            child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: previewed ? const Color(0xFFD58D59) : (active ? pine : const Color(0xFFE4E0D6)), width: previewed ? 2.5 : (active ? 2 : 1)),
            ),
            child: Row(children: [
              Container(
                width: 52, height: 48,
                decoration: BoxDecoration(
                  gradient: type == 'background' ? LinearGradient(colors: backgroundGradients[index]) : null,
                  color: type == 'tiles' ? tileColors[index] : null,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(child: Text(type == 'tiles' ? tileSymbols[index] : ['🌱','🌅','💠','🌌'][index], style: const TextStyle(fontSize: 24))),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(name, style: const TextStyle(color: pine, fontWeight: FontWeight.w800)),
                const SizedBox(height: 3),
                Text(owned ? (active ? (language == 'ru' ? 'Выбрано' : 'Equipped') : (language == 'ru' ? 'Открыто' : 'Unlocked')) : '${costs[index]} XP', style: TextStyle(color: owned ? const Color(0xFF47765D) : const Color(0xFFB47737), fontSize: 12, fontWeight: FontWeight.w700)),
              ])),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: () => buy(type, index),
                style: FilledButton.styleFrom(backgroundColor: owned ? const Color(0xFFE5EDDF) : pine, foregroundColor: owned ? pine : Colors.white, padding: const EdgeInsets.symmetric(horizontal: 12)),
                child: Text(owned ? (active ? (language == 'ru' ? 'Выбрано' : 'Using') : (language == 'ru' ? 'Надеть' : 'Equip')) : (language == 'ru' ? 'Открыть' : 'Unlock')),
              ),
            ]),
          ));
        }
        Widget previewPanel() {
          final symbols = previewTiles == 0
              ? ['🌿', '🌸', '🦋']
              : previewTiles == 1
                  ? ['🌈', '🪷', '🌺']
                  : previewTiles == 2
                      ? ['💎', '💎', '💎']
                      : ['✨', '✨', '✨'];
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: backgroundGradients[previewBackground]),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  language == 'ru' ? 'ПРЕДПРОСМОТР · БЕЗ ПОКУПКИ' : 'PREVIEW · NO PURCHASE',
                  style: const TextStyle(color: pine, fontWeight: FontWeight.w900, fontSize: 11),
                ),
                const SizedBox(height: 8),
                Row(
                  children: symbols.map((symbol) => Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      height: 46,
                      decoration: BoxDecoration(
                        color: tileColors[previewTiles],
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white),
                      ),
                      child: Center(
                        child: Text(symbol, style: TextStyle(
                          fontSize: 24,
                          color: previewTiles == 3 ? Colors.white : pine,
                        )),
                      ),
                    ),
                  )).toList(),
                ),
                const SizedBox(height: 6),
                Text(
                  (language == 'ru' ? backgroundNamesRu[previewBackground] : backgroundNames[previewBackground]) +
                      ' · ' +
                      (language == 'ru' ? tileNamesRu[previewTiles] : tileNames[previewTiles]),
                  style: const TextStyle(color: pine, fontWeight: FontWeight.w700, fontSize: 11),
                ),
              ],
            ),
          );
        }
        return SafeArea(child: SizedBox(
          height: MediaQuery.of(sheetContext).size.height * .82,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Icon(Icons.shopping_bag_rounded, color: Color(0xFFD58D59), size: 30),
                const SizedBox(width: 8),
                Expanded(child: Text(language == 'ru' ? 'Магазин тем' : 'Theme shop', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: pine))),
                Text('${prefs.getInt('fita.rewards.xp') ?? playerXp} XP', style: const TextStyle(color: pine, fontWeight: FontWeight.w900)),
              ]),
              const SizedBox(height: 5),
              Text(language == 'ru' ? 'Нажми на карточку, чтобы посмотреть образ до покупки.' : 'Tap a card to preview before buying.', style: const TextStyle(color: Colors.black54, fontSize: 12)),
              previewPanel(),
              const SizedBox(height: 2),
              Expanded(child: ListView(children: [
                Text(language == 'ru' ? 'ФОНЫ' : 'BACKGROUNDS', style: const TextStyle(color: pine, fontSize: 11, letterSpacing: 1.5, fontWeight: FontWeight.w900)),
                const SizedBox(height: 8),
                ...List.generate(4, (i) => themeCard(type: 'background', index: i)),
                const SizedBox(height: 8),
                Text(language == 'ru' ? 'СТИЛИ ФИШЕК' : 'TILE STYLES', style: const TextStyle(color: pine, fontSize: 11, letterSpacing: 1.5, fontWeight: FontWeight.w900)),
                const SizedBox(height: 8),
                ...List.generate(4, (i) => themeCard(type: 'tiles', index: i)),
              ])),
            ]),
          ),
        ));
      }),
    );
    await _refreshPlayerXp();
  }

  void _settings(BuildContext context) => showModalBottomSheet(context: context, backgroundColor: cream, showDragHandle: true, builder: (context) => StatefulBuilder(builder: (context, setSheet) => Padding(
    padding: const EdgeInsets.fromLTRB(24, 8, 24, 30),
    child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(_tr(language, 'settings'), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: pine)),
      const SizedBox(height: 10),
      Text(_tr(language, 'language'), style: const TextStyle(fontSize: 11, letterSpacing: 1.5, color: pine, fontWeight: FontWeight.w900)),
      const SizedBox(height: 6),
      DropdownButtonFormField<String>(
        initialValue: language,
        decoration: const InputDecoration(filled: true, fillColor: Colors.white, border: OutlineInputBorder()),
        items: const [
          DropdownMenuItem(value: 'en', child: Text('English')),
          DropdownMenuItem(value: 'ru', child: Text('Русский')),
          DropdownMenuItem(value: 'es', child: Text('Español')),
          DropdownMenuItem(value: 'fr', child: Text('Français')),
          DropdownMenuItem(value: 'de', child: Text('Deutsch')),
          DropdownMenuItem(value: 'pt', child: Text('Português')),
          DropdownMenuItem(value: 'it', child: Text('Italiano')),
          DropdownMenuItem(value: 'tr', child: Text('Türkçe')),
          DropdownMenuItem(value: 'zh', child: Text('中文')),
          DropdownMenuItem(value: 'ja', child: Text('日本語')),
          DropdownMenuItem(value: 'ko', child: Text('한국어')),
          DropdownMenuItem(value: 'hi', child: Text('हिन्दी')),
          DropdownMenuItem(value: 'ar', child: Text('العربية')),
        ],
        onChanged: (v) async { if (v == null) return; setState(() => language = v); setSheet(() {}); final p = await SharedPreferences.getInstance(); await p.setString('fita.language', v); },
      ),
      const SizedBox(height: 12),
      SwitchListTile(value: sound, onChanged: (v) { setState(() => sound = v); setSheet(() {}); _saveProgress(); }, title: Text(_tr(language, 'sound')), secondary: const Icon(Icons.volume_up_rounded, color: pine)),
      SwitchListTile(
        value: musicEnabled,
        onChanged: (v) async { await _setMusicEnabled(v); setSheet(() {}); },
        title: Text(language == 'ru' ? 'Фоновая музыка' : 'Ambient music'),
        subtitle: Text(language == 'ru' ? 'Спокойная музыка с плавным затуханием' : 'Calm music with smooth fades'),
        secondary: const Icon(Icons.music_note_rounded, color: pine),
      ),
      SwitchListTile(value: haptics, onChanged: (v) { setState(() => haptics = v); setSheet(() {}); _saveProgress(); }, title: Text(_tr(language, 'haptics')), secondary: const Icon(Icons.vibration_rounded, color: pine)),
      SwitchListTile(value: comboEffects, onChanged: (v) async { setState(() => comboEffects = v); setSheet(() {}); final p = await SharedPreferences.getInstance(); await p.setBool('fita.combo.effects', v); }, title: Text(_tr(language, 'comboEffects')), subtitle: Text(_tr(language, 'comboEffectsNote')), secondary: const Icon(Icons.bolt_rounded, color: pine)),
      const Divider(height: 20),
      SizedBox(width: double.infinity, child: OutlinedButton.icon(
        onPressed: () { Navigator.of(context).pop(); _showThemeShop(); },
        icon: const Icon(Icons.shopping_bag_rounded),
        label: Text(language == 'ru' ? 'Открыть магазин тем' : 'Open theme shop'),
      )),
      const SizedBox(height: 10),
      Text(_tr(language, 'backgroundTheme'), style: const TextStyle(fontSize: 11, letterSpacing: 1.5, color: pine, fontWeight: FontWeight.w900)),
      const SizedBox(height: 8),
      Wrap(spacing: 10, children: List.generate(4, (i) => GestureDetector(
        onTap: () async { final p = await SharedPreferences.getInstance(); final owned = p.getStringList('fita.shop.owned.background') ?? <String>['0']; if (!owned.contains('$i')) { _message(context, language == 'ru' ? 'Тема закрыта — открой её в магазине за XP' : 'Theme locked — unlock it in the XP shop'); return; } setState(() => backgroundTheme = i); setSheet(() {}); await p.setInt('fita.theme.background', i); },
        child: Container(width: 48, height: 42, decoration: BoxDecoration(gradient: LinearGradient(colors: [[const Color(0xFFE8F0DE), const Color(0xFFFFF6E7)], [const Color(0xFFFFD6E8), const Color(0xFFFFE7A8)], [const Color(0xFFB8F2E6), const Color(0xFFCDB4DB)], [const Color(0xFF171B45), const Color(0xFF302B63)]][i]), borderRadius: BorderRadius.circular(13), border: Border.all(color: backgroundTheme == i ? pine : Colors.white, width: backgroundTheme == i ? 3 : 1))),
      ))),
      const SizedBox(height: 14),
      Text(_tr(language, 'tileStyle'), style: const TextStyle(fontSize: 11, letterSpacing: 1.5, color: pine, fontWeight: FontWeight.w900)),
      const SizedBox(height: 8),
      Wrap(spacing: 10, children: List.generate(4, (i) => GestureDetector(
        onTap: () async { final p = await SharedPreferences.getInstance(); final owned = p.getStringList('fita.shop.owned.tiles') ?? <String>['0']; if (!owned.contains('$i')) { _message(context, language == 'ru' ? 'Стиль закрыт — открой его в магазине за XP' : 'Style locked — unlock it in the XP shop'); return; } setState(() => tileTheme = i); setSheet(() {}); await p.setInt('fita.theme.tiles', i); },
        child: Container(width: 48, height: 42, decoration: BoxDecoration(color: [[const Color(0xFFFFFDF6)], [const Color(0xFFFFD6E8)], [const Color(0xFFB8F2E6)], [const Color(0xFF22254B)]][i][0], borderRadius: BorderRadius.circular(13), border: Border.all(color: tileTheme == i ? pine : Colors.white, width: tileTheme == i ? 3 : 1)), child: Center(child: Text(['🌿','🌈','💎','✨'][i]))),
      ))),
      const SizedBox(height: 12),
      Row(children: [Expanded(child: Text(_tr(language, 'animationIntensity'), style: const TextStyle(color: pine, fontWeight: FontWeight.w700))), Text([_tr(language, 'low'),_tr(language, 'normal'),_tr(language, 'extra')][animationLevel], style: const TextStyle(color: pine))]),
      Slider(value: animationLevel.toDouble(), min: 0, max: 2, divisions: 2, activeColor: pine, onChanged: (v) async { setState(() => animationLevel = v.round()); setSheet(() {}); final p = await SharedPreferences.getInstance(); await p.setInt('fita.animation.level', v.round()); }),
      const SizedBox(height: 8),
      Text(_tr(language, 'preferencesNote'), style: const TextStyle(color: Colors.black54, fontSize: 12)),
    ])),
  )));

  @override
  void dispose() {
    _musicFadeTimer?.cancel();
    unawaited(_musicPlayer.stop());
    unawaited(_musicPlayer.dispose());
    super.dispose();
  }

  void _message(BuildContext context, String message) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}

class _MultiplayerLobby extends StatefulWidget {
  final String language;
  final Future<void> Function(MultiplayerRoom room) onRoomReady;
  const _MultiplayerLobby({required this.language, required this.onRoomReady});

  @override
  State<_MultiplayerLobby> createState() => _MultiplayerLobbyState();
}

class _MultiplayerLobbyState extends State<_MultiplayerLobby> {
  final TextEditingController _codeController = TextEditingController();
  bool _busy = false;
  String? _error;

  Future<void> _run(Future<MultiplayerRoom> Function() action) async {
    if (_busy) return;
    setState(() { _busy = true; _error = null; });
    try {
      final room = await action();
      if (!mounted) return;
      await widget.onRoomReady(room);
    } catch (error) {
      if (mounted) setState(() => _error = error.toString().replaceFirst('Bad state: ', '').replaceFirst('FormatException: ', ''));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Padding(
      padding: EdgeInsets.fromLTRB(22, 8, 22, 22 + MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('🌿 Play with a friend', style: TextStyle(fontSize: 23, fontWeight: FontWeight.w900, color: pine)),
          const SizedBox(height: 6),
          const Text('Create a room and send its 6-character code to a friend, or enter their code. Both players get the same solvable board.', style: TextStyle(color: ink, height: 1.4)),
          const SizedBox(height: 16),
          SizedBox(width: double.infinity, child: FilledButton.icon(
            onPressed: _busy ? null : () => _run(MultiplayerService.instance.createRoom),
            icon: const Icon(Icons.add_link_rounded),
            label: Text(_busy ? 'Connecting…' : 'Create room'),
            style: FilledButton.styleFrom(backgroundColor: pine, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14)),
          )),
          const SizedBox(height: 14),
          TextField(
            controller: _codeController,
            textCapitalization: TextCapitalization.characters,
            maxLength: 6,
            textInputAction: TextInputAction.go,
            decoration: const InputDecoration(
              labelText: 'Friend’s room code',
              hintText: 'ABC234',
              counterText: '',
              border: OutlineInputBorder(),
              filled: true,
              fillColor: Colors.white,
              prefixIcon: Icon(Icons.vpn_key_rounded),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(width: double.infinity, child: OutlinedButton.icon(
            onPressed: _busy ? null : () => _run(() => MultiplayerService.instance.joinRoom(_codeController.text)),
            icon: const Icon(Icons.login_rounded),
            label: const Text('Join room'),
            style: OutlinedButton.styleFrom(foregroundColor: pine, padding: const EdgeInsets.symmetric(vertical: 14)),
          )),
          if (_error != null) Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(_error!, style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(height: 10),
          const Text('Online play requires Firebase to be configured and Firestore rules deployed.', style: TextStyle(color: Colors.black54, fontSize: 12)),
        ],
      )),
    ),
  );
}

class GameScreen extends StatefulWidget {
  final int level;
  final int? seed;
  final String? dailyDate;
  final String? roomCode;
  final String? playerUid;
  final bool sound;
  final bool haptics;
  final int backgroundTheme;
  final int tileTheme;
  final int animationLevel;
  final bool comboEffects;
  final String language;
  const GameScreen({super.key, required this.level, this.seed, this.dailyDate, this.roomCode, this.playerUid, this.sound = true, this.haptics = true, this.backgroundTheme = 0, this.tileTheme = 0, this.animationLevel = 2, this.comboEffects = true, this.language = 'en'});
  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  static const _tileSets = [
    ['🍃','🌼','🍄','🦋','🌿','🍐','🌸','🐝','🌙','🍀','🌻','🪷','🌷','🌱','🌳','🍁','🍂','🌾','🌵','🌴','🪴','🪻','🐞','🐛','🐌','🐢','🦜','🦚','🪺','🍇','🍉','🍊','🍋','🍓','🫐','🥝'],
    ['🌈','⭐','💖','🦄','🍭','🧁','🎀','🫧','🌟','🍬','💫','🩷','🎈','🎨','🎁','🪅','🎠','🧸','🍰','🍡','🍥','🍮','🍦','🍨','🍧','🍩','🍪','🥨','🧋','🪄','🎐','🪷','🌺','💐','🪻','🌹'],
    ['💎','🔮','🪐','☄️','🌌','🧿','🪄','✨','🌙','💠','🌀','⭐','🌠','🛸','👽','🚀','🛰️','🌍','🌕','🌑','🌘','🌗','🌖','🌔','☀️','🌞','🌟','🌈','⚡','🌎','🔭','🪬','💫','🌃','🧬','🪷'],
    ['🔥','⚡','🌊','🌪️','☀️','🌈','💥','🌟','🪩','💫','🧨','✨','🎇','🎆','🔆','🌞','🌤️','🌩️','🌫️','🌬️','💧','💦','🫧','🌀','🌋','🌡️','☄️','🌠','🔮','💎','🪐','🛸','🚀','⚙️','🔋','💡'],
  ];
  static const _tileColors = [
    [Color(0xFFFFFDF6), Color(0xFFFFE4B5), Color(0xFFE3EDD9), Color(0xFFD9E8EF)],
    [Color(0xFFFFD6E8), Color(0xFFFFA6A6), Color(0xFFFFE7A8), Color(0xFFCDB4DB)],
    [Color(0xFFB8F2E6), Color(0xFFBDE0FE), Color(0xFFCDB4DB), Color(0xFFFFC8DD)],
    [Color(0xFF22254B), Color(0xFF4C3F91), Color(0xFF00C9A7), Color(0xFFFFC857)],
  ];
  late List<String> tiles;
  late List<_TileSpot> spots;
  int burst = 0;
  Offset _burstCenter = const Offset(.5, .52);
  final GlobalKey _gameStackKey = GlobalKey();
  int matchStreak = 0;
  int bestComboStreak = 0;
  int activeComboLevel = 0;
  int comboPopupLevel = 0;
  Timer? _comboPopupTimer;
  bool shaking = false;
  final Set<int> removed = {};
  int? selected;
  int? mismatch;
  int moves = 0;
  int pairs = 8;
  bool busy = false;
  bool finished = false;
  int? hintA;
  int? hintB;
  final List<_GameSnapshot> _history = <_GameSnapshot>[];
  late final AnimationController _winController;
  late final AnimationController _flightController;
  final List<GlobalKey> _slotKeys = List.generate(4, (_) => GlobalKey());
  final List<int?> storageSlots = List<int?>.filled(4, null);
  final Map<int, GlobalKey> _tileKeys = <int, GlobalKey>{};
  OverlayEntry? _flightEntry;
  late final Stopwatch _clock;
  final AudioPlayer _matchPlayer = AudioPlayer();
  final TransformationController _boardController = TransformationController();
  bool _boardFitMode = false;
  late final AnimationController _boardFitController;
  Animation<Matrix4>? _boardFitAnimation;
  Timer? _ticker;
  StreamSubscription<Map<String, dynamic>?>? _roomSubscription;
  int opponentPairs = 72;
  bool opponentWon = false;
  bool opponentJoined = false;
  String get elapsed {
    final s = _clock.elapsed.inSeconds;
    return '${(s ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')}';
  }

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((prefs) {
      if (mounted) setState(() => bestComboStreak = prefs.getInt('fita.combo.bestStreak') ?? 0);
    });
    _winController = AnimationController(vsync: this, duration: const Duration(milliseconds: 850));
    _boardFitController = AnimationController(vsync: this, duration: const Duration(milliseconds: 420));
    _boardFitController.addListener(() {
      final animation = _boardFitAnimation;
      if (animation != null && mounted) _boardController.value = animation.value;
    });
    _flightController = AnimationController(vsync: this, duration: Duration(milliseconds: widget.animationLevel == 0 ? 180 : 420));
    _flightController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _flightEntry?.remove();
        _flightEntry = null;
      }
    });
    _clock = Stopwatch()..start();
    unawaited(_matchPlayer.setReleaseMode(ReleaseMode.stop));
    // Warm all four sound variants before the first successful match.
    Future<void>.delayed(Duration.zero, () {
      for (var level = 0; level <= 3; level++) {
        _soundCache.putIfAbsent(level, () => _buildBurstWav(comboLevel: level));
      }
    });
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && !finished) setState(() {});
    });
    _newBoard();
    _listenToRoom();
  }

  void _listenToRoom() {
    if (widget.roomCode == null || widget.playerUid == null) return;
    _roomSubscription = MultiplayerService.instance.watchRoom(widget.roomCode!).listen((data) {
      if (data == null || !mounted) return;
      final isHost = data['hostUid'] == widget.playerUid;
      setState(() {
        opponentJoined = data['guestUid'] != null;
        opponentPairs = ((isHost ? data['guestPairs'] : data['hostPairs']) as num?)?.toInt() ?? 72;
        opponentWon = (isHost ? data['guestWon'] : data['hostWon']) == true;
      });
    }, onError: (_) {});
  }

  Future<void> _syncRoomProgress() async {
    final code = widget.roomCode;
    final uid = widget.playerUid;
    if (code == null || uid == null) return;
    try {
      await MultiplayerService.instance.updateProgress(
        code: code,
        uid: uid,
        pairsLeft: pairs,
        won: finished,
      );
    } catch (_) {
      // A temporary connection issue must not interrupt the local match.
    }
  }

  Future<void> _recordComboStreak() async {
    if (matchStreak <= bestComboStreak) return;
    final newRecord = matchStreak;
    if (mounted) setState(() => bestComboStreak = newRecord);
    try {
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getInt('fita.combo.bestStreak') ?? 0;
      if (newRecord > stored) await prefs.setInt('fita.combo.bestStreak', newRecord);
      await _checkAchievementUnlocks(prefs);
    } catch (_) {
      // Keep the in-memory record for this session if local storage is unavailable.
    }
  }

  Future<void> _checkAchievementUnlocks(SharedPreferences prefs) async {
    if (!mounted) return;
    final wins = prefs.getInt('fita.stats.wins') ?? 0;
    final dailyWins = prefs.getInt('fita.stats.dailyWins') ?? 0;
    final highestLevel = prefs.getInt('fita.stats.highestLevel') ?? widget.level;
    final streak = prefs.getInt('fita.daily.streak') ?? 0;
    final combo = prefs.getInt('fita.combo.bestStreak') ?? bestComboStreak;
    final goals = <({String id, String title, String subtitle, IconData icon, int value, int target, int xp})>[
      (id: 'first', title: widget.language == 'ru' ? 'Первый шаг' : 'First steps', subtitle: widget.language == 'ru' ? 'Первая победа' : 'First game won', icon: Icons.flag_rounded, value: wins, target: 1, xp: 25),
      (id: 'wins10', title: widget.language == 'ru' ? 'Мастер головоломок' : 'Puzzle master', subtitle: widget.language == 'ru' ? '10 побед' : 'Win 10 games', icon: Icons.auto_awesome_rounded, value: wins, target: 10, xp: 75),
      (id: 'wins50', title: widget.language == 'ru' ? 'Легенда сада' : 'Garden legend', subtitle: widget.language == 'ru' ? '50 побед' : 'Win 50 games', icon: Icons.park_rounded, value: wins, target: 50, xp: 200),
      (id: 'level10', title: widget.language == 'ru' ? 'Путь открыт' : 'Pathfinder', subtitle: widget.language == 'ru' ? 'Достигнут уровень 10' : 'Reach level 10', icon: Icons.route_rounded, value: highestLevel, target: 10, xp: 50),
      (id: 'level100', title: widget.language == 'ru' ? 'Вершина пути' : 'Trailblazer', subtitle: widget.language == 'ru' ? 'Достигнут уровень 100' : 'Reach level 100', icon: Icons.military_tech_rounded, value: highestLevel, target: 100, xp: 250),
      (id: 'daily1', title: widget.language == 'ru' ? 'Роса дня' : 'Daily dew', subtitle: widget.language == 'ru' ? 'Ежедневный уровень пройден' : 'Complete a daily level', icon: Icons.wb_twilight_rounded, value: dailyWins, target: 1, xp: 30),
      (id: 'streak3', title: widget.language == 'ru' ? 'Ритм недели' : 'Weekly rhythm', subtitle: widget.language == 'ru' ? '3 дня подряд' : '3-day streak', icon: Icons.local_fire_department_rounded, value: streak, target: 3, xp: 60),
      (id: 'streak7', title: widget.language == 'ru' ? 'Неудержимый' : 'Unstoppable', subtitle: widget.language == 'ru' ? '7 дней подряд' : '7-day streak', icon: Icons.bolt_rounded, value: streak, target: 7, xp: 120),
      (id: 'combo5', title: widget.language == 'ru' ? 'Комбо x5' : 'Combo x5', subtitle: widget.language == 'ru' ? '5 пар подряд' : '5 matches in a row', icon: Icons.flash_on_rounded, value: combo, target: 5, xp: 40),
      (id: 'combo10', title: widget.language == 'ru' ? 'Комбо x10' : 'Combo x10', subtitle: widget.language == 'ru' ? '10 пар подряд' : '10 matches in a row', icon: Icons.local_fire_department_rounded, value: combo, target: 10, xp: 90),
    ];
    final unlocked = prefs.getStringList('fita.achievements.unlocked') ?? <String>[];
    var totalXp = prefs.getInt('fita.rewards.xp') ?? 0;
    var lifetimeXp = prefs.getInt('fita.rewards.totalXp') ?? totalXp;
    await prefs.setInt('fita.rewards.totalXp', lifetimeXp);
    final newlyUnlocked = goals.where((g) => g.value >= g.target && !unlocked.contains(g.id)).toList();
    if (newlyUnlocked.isEmpty) return;
    for (final achievement in newlyUnlocked) {
      unlocked.add(achievement.id);
      totalXp += achievement.xp;
      lifetimeXp += achievement.xp;
    }
    await prefs.setStringList('fita.achievements.unlocked', unlocked);
    await prefs.setInt('fita.rewards.xp', totalXp);
    await prefs.setInt('fita.rewards.totalXp', lifetimeXp);
    if (!mounted) return;
    for (final achievement in newlyUnlocked) {
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      messenger.showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        elevation: 0,
        duration: const Duration(seconds: 3),
        padding: EdgeInsets.zero,
        content: TweenAnimationBuilder<double>(
          tween: Tween(begin: .72, end: 1),
          duration: const Duration(milliseconds: 520),
          curve: Curves.elasticOut,
          builder: (context, scale, child) => Transform.scale(scale: scale, child: child),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF315B45), Color(0xFF4C8061)]),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFFFD27A), width: 1.5),
              boxShadow: const [BoxShadow(color: Color(0x55315B45), blurRadius: 18, offset: Offset(0, 6))],
            ),
            child: Row(children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(color: Color(0xFFFFE4B5), shape: BoxShape.circle),
                child: Icon(achievement.icon, color: Color(0xFF315B45), size: 27),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                Text(widget.language == 'ru' ? 'ДОСТИЖЕНИЕ ОТКРЫТО!' : 'ACHIEVEMENT UNLOCKED!', style: const TextStyle(color: Color(0xFFFFD27A), fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
                const SizedBox(height: 3),
                Text(achievement.title, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w900)),
                Text(achievement.subtitle, style: const TextStyle(color: Colors.white70, fontSize: 11)),
              ])),
              Column(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.stars_rounded, color: Color(0xFFFFD27A), size: 23),
                Text('+${achievement.xp} XP', style: const TextStyle(color: Color(0xFFFFD27A), fontSize: 12, fontWeight: FontWeight.w900)),
              ]),
            ]),
          ),
        ),
      ));
      await Future<void>.delayed(const Duration(milliseconds: 250));
    }
  }

  bool _availableInState(int index, List<_TileSpot> layout, Set<int> gone) =>
      MahjongRules.isAvailable(index, layout, gone);

  void _flyTile(int index, {int slot = 0}) {
    if (widget.animationLevel == 0 || !mounted) return;
    final sourceContext = _tileKeys[index]?.currentContext;
    final targetContext = _slotKeys[slot.clamp(0, 3).toInt()].currentContext;
    if (sourceContext == null || targetContext == null) return;
    final sourceBox = sourceContext.findRenderObject() as RenderBox?;
    final targetBox = targetContext.findRenderObject() as RenderBox?;
    final overlay = Overlay.of(context);
    final overlayBox = overlay.context.findRenderObject() as RenderBox?;
    if (sourceBox == null || targetBox == null || overlayBox == null) return;
    final source = sourceBox.localToGlobal(Offset.zero, ancestor: overlayBox);
    final target = targetBox.localToGlobal(Offset.zero, ancestor: overlayBox);
    final start = source + Offset(sourceBox.size.width / 2, sourceBox.size.height / 2);
    final end = target + Offset(targetBox.size.width / 2, targetBox.size.height / 2);
    _flightEntry?.remove();
    _flightController.reset();
    _flightEntry = OverlayEntry(builder: (context) => IgnorePointer(
      child: AnimatedBuilder(
        animation: _flightController,
        builder: (context, child) {
          final t = Curves.easeInOutCubic.transform(_flightController.value);
          final point = Offset.lerp(start, end, t)!;
          final size = sourceBox.size.width + (min(targetBox.size.width * .72, sourceBox.size.width) - sourceBox.size.width) * t;
          return Positioned(
            left: point.dx - size / 2,
            top: point.dy - size / 2,
            width: size,
            height: size,
            child: Opacity(
              opacity: (1 - .18 * t).clamp(0.0, 1.0),
              child: Material(
                color: Colors.transparent,
                child: Container(
                  decoration: BoxDecoration(
                    color: _tileColors[widget.tileTheme.clamp(0, 3).toInt()][1],
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(color: const Color(0xFFFFD27A), width: 2.5),
                    boxShadow: [BoxShadow(color: pine.withValues(alpha: .35), blurRadius: 20, spreadRadius: 3)],
                  ),
                  child: Center(child: Text(tiles[index], style: TextStyle(fontSize: size * .52))),
                ),
              ),
            ),
          );
        },
      ),
    ));
    overlay.insert(_flightEntry!);
    _flightController.forward();
  }


  void _newBoard() {
    pairs = 72;
    const tileCount = 144;
    spots = MahjongRules.classicTurtleLayout();
    final solvableOrder = MahjongRules.classicRemovalOrder(spots);
    final symbols = _tileSets[widget.tileTheme.clamp(0, 3).toInt()].toList()
      ..shuffle(Random(widget.seed ?? (widget.level * 31 + DateTime.now().millisecondsSinceEpoch % 997)));
    tiles = List.filled(tileCount, '');
    // Four copies of each of the 36 faces: each face forms two matching pairs.
    for (var p = 0; p < pairs; p++) {
      final symbol = symbols[p ~/ 2];
      tiles[solvableOrder[p * 2]] = symbol;
      tiles[solvableOrder[p * 2 + 1]] = symbol;
    }
    removed.clear();
    storageSlots.fillRange(0, storageSlots.length, null);
    _history.clear();
    selected = null;
    mismatch = null;
    hintA = null;
    hintB = null;
    moves = 0;
    matchStreak = 0;
    activeComboLevel = 0;
    busy = false;
    finished = false;
    _clock..reset()..start();
  }

  Uint8List _buildBurstWav({int comboLevel = 0}) {
    // A short, soft mallet chord. Generate PCM once and cache it so matching
    // never has to synthesize audio on the interaction path.
    const sampleRate = 22050;
    final duration = comboLevel == 3
        ? .95
        : comboLevel == 2
            ? .82
            : comboLevel == 1
                ? .68
                : .56;
    final sampleCount = (sampleRate * duration).round();
    final bytes = Uint8List(44 + sampleCount * 2);
    final header = ByteData.sublistView(bytes);
    void writeTag(int offset, String tag) {
      for (var i = 0; i < tag.length; i++) {
        bytes[offset + i] = tag.codeUnitAt(i);
      }
    }
    writeTag(0, 'RIFF');
    header.setUint32(4, bytes.length - 8, Endian.little);
    writeTag(8, 'WAVE');
    writeTag(12, 'fmt ');
    header.setUint32(16, 16, Endian.little);
    header.setUint16(20, 1, Endian.little);
    header.setUint16(22, 1, Endian.little);
    header.setUint32(24, sampleRate, Endian.little);
    header.setUint32(28, sampleRate * 2, Endian.little);
    header.setUint16(32, 2, Endian.little);
    header.setUint16(34, 16, Endian.little);
    writeTag(36, 'data');
    header.setUint32(40, sampleCount * 2, Endian.little);

    final root = 523.25 + comboLevel * 55.0;
    final notes = <double>[root, root * 1.25, root * 1.5];
    final offsets = <double>[0, .024, .048];
    for (var i = 0; i < sampleCount; i++) {
      final t = i / sampleRate;
      var sample = 0.0;
      for (var note = 0; note < notes.length; note++) {
        final noteTime = t - offsets[note];
        if (noteTime < 0) continue;
        // Give every note a gentle attack and a real release tail. The
        // previous fast exponential decay made the chord sound clipped.
        final attack = (noteTime / .045).clamp(0.0, 1.0);
        final release = ((duration - t) / .18).clamp(0.0, 1.0);
        final smoothAttack = attack * attack * (3 - 2 * attack);
        final smoothRelease = release * release * (3 - 2 * release);
        final envelope = smoothAttack * smoothRelease *
            exp(-noteTime * (comboLevel == 0 ? 3.8 : 2.8));
        final fundamental = sin(2 * pi * notes[note] * noteTime);
        final overtone = sin(2 * pi * notes[note] * 2.76 * noteTime) * .12;
        sample += (fundamental + overtone) * envelope *
            (note == 0 ? .23 : note == 1 ? .18 : .14);
      }
      final pcm = (sample * 26000).round().clamp(-32768, 32767).toInt();
      header.setInt16(44 + i * 2, pcm, Endian.little);
    }
    return bytes;
  }

  static final Map<int, Uint8List> _soundCache = <int, Uint8List>{};

  Future<void> _playMatchBurst({int comboLevel = 0}) async {
    try {
      final soundKey = comboLevel.clamp(0, 3).toInt();
      final soundData = _soundCache.putIfAbsent(
        soundKey,
        () => _buildBurstWav(comboLevel: soundKey),
      );
      await _matchPlayer.stop();
      await _matchPlayer.play(BytesSource(soundData), volume: .68);
    } catch (_) {
      // Sound is optional; matching and animations must work if audio is unavailable.
    }
  }

  void _feedback({bool success = false, int comboLevel = 0}) {
    if (widget.haptics) {
      if (success) {
        // Two light taps communicate a successful match without being intrusive.
        HapticFeedback.lightImpact();
      } else {
        HapticFeedback.selectionClick();
      }
    }
    if (widget.sound) {
      if (success) {
        unawaited(_playMatchBurst(comboLevel: comboLevel));
      } else {
        SystemSound.play(SystemSoundType.click);
      }
    }
  }

  void _captureBurstCenter(int first, int second) {
    final stackContext = _gameStackKey.currentContext;
    final firstContext = _tileKeys[first]?.currentContext;
    final secondContext = _tileKeys[second]?.currentContext;
    if (stackContext == null || firstContext == null || secondContext == null) return;
    final stackBox = stackContext.findRenderObject() as RenderBox?;
    final firstBox = firstContext.findRenderObject() as RenderBox?;
    final secondBox = secondContext.findRenderObject() as RenderBox?;
    if (stackBox == null || firstBox == null || secondBox == null ||
        !stackBox.hasSize || !firstBox.hasSize || !secondBox.hasSize) return;
    final firstCenter = firstBox.localToGlobal(
      Offset(firstBox.size.width / 2, firstBox.size.height / 2),
    );
    final secondCenter = secondBox.localToGlobal(
      Offset(secondBox.size.width / 2, secondBox.size.height / 2),
    );
    final midpoint = stackBox.globalToLocal(Offset(
      (firstCenter.dx + secondCenter.dx) / 2,
      (firstCenter.dy + secondCenter.dy) / 2,
    ));
    _burstCenter = Offset(
      (midpoint.dx / stackBox.size.width).clamp(0.0, 1.0).toDouble(),
      (midpoint.dy / stackBox.size.height).clamp(0.0, 1.0).toDouble(),
    );
  }

  Future<void> _tap(int i) async {
    if (busy || finished || removed.contains(i)) return;
    if (!_availableInState(i, spots, removed)) {
      if (widget.haptics) HapticFeedback.selectionClick();
      return;
    }

    final matchingSlot = storageSlots.indexWhere(
      (stored) => stored != null && tiles[stored] == tiles[i],
    );
    final freeSlot = storageSlots.indexWhere((stored) => stored == null);
    if (matchingSlot < 0 && freeSlot < 0) {
      _finishLoss();
      return;
    }

    _history.add(_GameSnapshot(
      removed: Set<int>.from(removed),
      selected: selected,
      moves: moves,
      pairs: pairs,
      hintA: hintA,
      hintB: hintB,
      storageSlots: List<int?>.from(storageSlots),
    ));
    final targetSlot = matchingSlot >= 0 ? matchingSlot : freeSlot;
    if (matchingSlot >= 0) _captureBurstCenter(i, storageSlots[matchingSlot]!);
    WidgetsBinding.instance.addPostFrameCallback((_) => _flyTile(i, slot: targetSlot));

    setState(() {
      moves++;
      hintA = null;
      hintB = null;
      selected = null;
      removed.add(i);
      if (matchingSlot >= 0) {
        storageSlots[matchingSlot] = null;
        pairs--;
      } else {
        storageSlots[freeSlot] = i;
      }
    });

    if (matchingSlot >= 0) {
      matchStreak++;
      _recordComboStreak();
      final comboLevel = matchStreak == 10 ? 3 : matchStreak == 5 ? 2 : matchStreak == 3 ? 1 : 0;
      activeComboLevel = widget.comboEffects ? comboLevel : 0;
      comboPopupLevel = widget.comboEffects ? comboLevel : 0;
      _comboPopupTimer?.cancel();
      if (comboPopupLevel > 0) {
        _comboPopupTimer = Timer(Duration(milliseconds: comboLevel == 3 ? 1900 : comboLevel == 2 ? 1600 : 1300), () {
          if (mounted) setState(() => comboPopupLevel = 0);
        });
      }
      _feedback(success: true, comboLevel: widget.comboEffects ? comboLevel : 0);
      setState(() {
        burst++;
        shaking = true;
      });
      if (pairs > 0) unawaited(_syncRoomProgress());
      Future.delayed(const Duration(milliseconds: 420), () {
        if (mounted) setState(() => shaking = false);
      });
      if (pairs == 0) {
        finished = true;
        unawaited(_syncRoomProgress());
        _clock.stop();
        _winController.forward(from: 0);
        if (mounted) _showWin();
      }
    } else {
      matchStreak = 0;
      activeComboLevel = 0;
      comboPopupLevel = 0;
      _comboPopupTimer?.cancel();
      _feedback();
      if (storageSlots.every((stored) => stored != null)) _finishLoss();
    }
  }

  void _finishLoss() {
    if (finished || !mounted) return;
    setState(() {
      finished = true;
      selected = null;
      busy = false;
    });
    _clock.stop();
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 26, vertical: 24),
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0, end: 1),
          duration: const Duration(milliseconds: 520),
          curve: Curves.easeOutCubic,
          builder: (context, progress, child) => Opacity(
            opacity: progress.clamp(0.0, 1.0),
            child: Transform.scale(
              scale: .88 + .12 * Curves.easeOutBack.transform(progress),
              child: child,
            ),
          ),
          child: Container(
          decoration: BoxDecoration(
            color: cream,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: const Color(0xFFE6C99A), width: 1.5),
            boxShadow: [
              BoxShadow(color: pine.withValues(alpha: .22), blurRadius: 30, offset: const Offset(0, 14)),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Stack(
              children: [
                Positioned(top: -34, right: -24, child: Icon(Icons.spa_rounded, size: 150, color: leaf.withValues(alpha: .09))),
                Positioned(bottom: -35, left: -22, child: Icon(Icons.auto_awesome_rounded, size: 140, color: const Color(0xFFD58D59).withValues(alpha: .10))),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 84,
                        height: 84,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFFFFE5B7), Color(0xFFE7B77C)],
                          ),
                          boxShadow: [BoxShadow(color: const Color(0xFFD58D59).withValues(alpha: .28), blurRadius: 18, offset: const Offset(0, 7))],
                        ),
                        child: const Icon(Icons.grid_view_rounded, size: 42, color: pine),
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        'Квадраты заполнены',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 23, height: 1.15, color: pine, fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Все 4 квадрата заняты фишками без пары. Освободи место, чтобы продолжить!',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, height: 1.45, color: pine.withValues(alpha: .82), fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: List.generate(4, (slot) => Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(right: slot == 3 ? 0 : 6),
                            child: AspectRatio(
                              aspectRatio: 1,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF8E9),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0xFFE3CDA8)),
                                ),
                                child: Center(
                                  child: Text(
                                    storageSlots[slot] == null ? '✦' : tiles[storageSlots[slot]!],
                                    style: const TextStyle(fontSize: 27, color: pine, fontWeight: FontWeight.w800),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )),
                      ),
                      const SizedBox(height: 22),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: pine,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          icon: const Icon(Icons.replay_rounded),
                          onPressed: () {
                            Navigator.of(dialogContext).pop();
                            setState(_newBoard);
                          },
                          label: const Text('Начать заново', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        ),
      ),
    );
  }

    void _hint() {
    if (busy || finished) return;
    final open = List.generate(tiles.length, (i) => i)
      .where((i) => _availableInState(i, spots, removed)).toList();
    for (var a = 0; a < open.length; a++) {
      for (var b = a + 1; b < open.length; b++) {
        if (tiles[open[a]] == tiles[open[b]]) {
          setState(() {
            selected = null;
            hintA = open[a];
            hintB = open[b];
          });
          if (widget.haptics) HapticFeedback.selectionClick();
          return;
        }
      }
    }
  }

  void _undo() {
    if (busy || _history.isEmpty) return;
    final previous = _history.removeLast();
    setState(() {
      removed
        ..clear()
        ..addAll(previous.removed);
      selected = previous.selected;
      moves = previous.moves;
      pairs = previous.pairs;
      hintA = previous.hintA;
      hintB = previous.hintB;
      storageSlots
        ..clear()
        ..addAll(previous.storageSlots);
      mismatch = null;
      finished = false;
    });
    _feedback();
  }

  void _shuffle() {
    if (busy || finished) return;
    setState(() {
      // Every matching pair occupies consecutive entries in a verified legal
      // removal order, so this randomized deal always has a solution.
      _newBoard();
      burst++;
    });
    _feedback();
  }

  void _showWin() async {
    if (!mounted) return;
    final prefs = await SharedPreferences.getInstance();
    final totalWins = (prefs.getInt('fita.stats.wins') ?? 0) + 1;
    await prefs.setInt('fita.stats.wins', totalWins);
    final oldHighestLevel = prefs.getInt('fita.stats.highestLevel') ?? 1;
    if (widget.dailyDate == null && widget.level > oldHighestLevel) {
      await prefs.setInt('fita.stats.highestLevel', widget.level);
    }
    final scores = prefs.getStringList('fita.leaderboard') ?? <String>[];
    final record = '${_tr(widget.language, 'player')}|${_tr(widget.language, 'level')} ${widget.level}';
    if (!scores.contains(record)) {
      scores.insert(0, record);
      await prefs.setStringList('fita.leaderboard', scores.take(20).toList());
    }
    await _checkAchievementUnlocks(prefs);
    if (!mounted) return;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => ScaleTransition(
        scale: CurvedAnimation(parent: _winController, curve: Curves.elasticOut),
        child: AlertDialog(
          backgroundColor: cream,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          icon: const Icon(Icons.celebration_rounded, size: 48, color: Color(0xFFD58D59)),
          title: Text(_tr(widget.language, 'wonTitle'), textAlign: TextAlign.center, style: const TextStyle(color: pine, fontWeight: FontWeight.w900)),
          content: Text('${_tr(widget.language, 'wonMessage')} $moves ${_tr(widget.language, 'movesLower')} · $elapsed', textAlign: TextAlign.center),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: pine, foregroundColor: Colors.white),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                Navigator.of(context).pop(true);
              },
              child: Text(_tr(widget.language, 'nextLevel')),
            ),
          ],
        ),
      ),
    );
  }

  void _fitBoard(double viewportWidth, double viewportHeight, double boardWidth, double boardHeight) {
    final scale = min(viewportWidth / boardWidth, viewportHeight / boardHeight)
        .clamp(0.35, 1.0)
        .toDouble();
    final dx = (viewportWidth - boardWidth * scale) / 2;
    final dy = (viewportHeight - boardHeight * scale) / 2;
    final target = Matrix4.identity()
      ..translateByDouble(dx, dy, 0, 1)
      ..scaleByDouble(scale, scale, scale, 1);
    _boardFitController.stop();
    _boardFitAnimation = Matrix4Tween(
      begin: Matrix4.copy(_boardController.value),
      end: target,
    ).animate(CurvedAnimation(
      parent: _boardFitController,
      curve: Curves.easeInOutCubic,
    ));
    _boardFitController.forward(from: 0);
  }

  void dispose() {
    _ticker?.cancel();
    _comboPopupTimer?.cancel();
    _flightEntry?.remove();
    _roomSubscription?.cancel();
    _flightController.dispose();
    _winController.dispose();
    _boardFitController.dispose();
    _boardController.dispose();
    _clock.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      backgroundColor: cream,
      foregroundColor: pine,
      title: Text(widget.dailyDate != null ? 'FITA Majong · Daily' : 'FITA Majong · ${widget.level}', style: const TextStyle(fontWeight: FontWeight.w900)),
      centerTitle: true,
      actions: [
        IconButton(tooltip: _tr(widget.language, 'undo'), onPressed: busy || _history.isEmpty ? null : _undo, icon: const Icon(Icons.undo_rounded)),
        IconButton(tooltip: _tr(widget.language, 'hint'), onPressed: busy || finished ? null : _hint, icon: const Icon(Icons.lightbulb_outline_rounded)),
      ],
    ),
    body: Stack(key: _gameStackKey, children: [
      Positioned.fill(child: NatureBackdrop(theme: widget.backgroundTheme)),
      Positioned.fill(child: _AmbientParticles(theme: widget.backgroundTheme)),
      if (widget.roomCode != null)
        Positioned(
          top: 6,
          left: 12,
          right: 12,
          child: Material(
            color: cream.withValues(alpha: .96),
            elevation: 2,
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              child: Row(children: [
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'ROOM ${widget.roomCode}  ·  ${opponentJoined ? 'LIVE RACE' : 'WAITING FOR FRIEND'}',
                      style: const TextStyle(color: pine, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: .8),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'You: ${72 - pairs}/72  ·  Friend: ${72 - opponentPairs}/72${opponentWon ? '  ·  Friend finished!' : ''}',
                      style: const TextStyle(color: ink, fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                  ],
                )),
                IconButton(
                  tooltip: 'Copy room code',
                  visualDensity: VisualDensity.compact,
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: widget.roomCode!));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Room code copied: ${widget.roomCode}')),
                    );
                  },
                  icon: const Icon(Icons.copy_rounded, color: pine, size: 18),
                ),
              ]),
            ),
          ),
        ),
      if (burst > 0) Positioned.fill(child: _BurstOverlay(key: ValueKey(burst), center: _burstCenter, theme: widget.backgroundTheme, intense: widget.animationLevel == 2 || activeComboLevel >= 2)),
      if (comboPopupLevel > 0) Positioned(
        top: 72,
        left: 0,
        right: 0,
        child: IgnorePointer(child: Center(child: TweenAnimationBuilder<double>(
          key: ValueKey('combo-popup-$comboPopupLevel-$matchStreak'),
          tween: Tween<double>(begin: 0.65, end: 1),
          duration: const Duration(milliseconds: 260),
          curve: Curves.elasticOut,
          builder: (context, scale, child) => Transform.scale(scale: scale, child: child),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: comboPopupLevel == 3 ? 28 : 22, vertical: comboPopupLevel == 3 ? 14 : 11),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: comboPopupLevel == 3
                ? const [Color(0xFFFF4D8D), Color(0xFFFFC857)]
                : comboPopupLevel == 2
                  ? const [Color(0xFF7B61FF), Color(0xFFFF4D8D)]
                  : const [Color(0xFF00A88F), Color(0xFF8ACB88)]),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [BoxShadow(color: (comboPopupLevel == 3 ? const Color(0xFFFF4D8D) : pine).withValues(alpha: .32), blurRadius: comboPopupLevel == 3 ? 28 : 18, spreadRadius: comboPopupLevel == 3 ? 3 : 1, offset: const Offset(0, 6))],
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(comboPopupLevel == 3 ? Icons.auto_awesome_rounded : comboPopupLevel == 2 ? Icons.bolt_rounded : Icons.star_rounded, color: Colors.white, size: comboPopupLevel == 3 ? 27 : 22),
              const SizedBox(width: 9),
              Text('COMBO x${comboPopupLevel == 1 ? 3 : comboPopupLevel == 2 ? 5 : 10}', style: TextStyle(color: Colors.white, fontSize: comboPopupLevel == 3 ? 25 : comboPopupLevel == 2 ? 22 : 20, fontWeight: FontWeight.w900, letterSpacing: 1.2, shadows: const [Shadow(color: Color(0x55000000), blurRadius: 5, offset: Offset(0, 2))])),
              const SizedBox(width: 5),
              const Icon(Icons.local_fire_department_rounded, color: Colors.white, size: 20),
            ]),
          ),
        ))),
      ),
      SafeArea(child: Padding(padding: const EdgeInsets.fromLTRB(14, 12, 14, 16), child: AnimatedContainer(duration: const Duration(milliseconds: 70), transform: Matrix4.translationValues(shaking ? (Random().nextDouble() - .5) * (10 + activeComboLevel * 4) : 0, shaking ? (Random().nextDouble() - .5) * (8 + activeComboLevel * 3) : 0, 0), child: Column(children: [
        Row(children: [
          _StatPill(label: _gameLabel(widget.language, 'moves'), value: '$moves'),
          const Spacer(),
          _StatPill(label: _gameLabel(widget.language, 'time'), value: elapsed),
          const Spacer(),
          _StatPill(label: _gameLabel(widget.language, 'pairs'), value: '${removed.length ~/ 2}/72'),
        ]),
        const SizedBox(height: 8),
        Align(alignment: Alignment.centerRight, child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(color: const Color(0xFFFFC857).withValues(alpha: .22), borderRadius: BorderRadius.circular(13), border: Border.all(color: const Color(0xFFFFC857).withValues(alpha: .65))),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.emoji_events_rounded, color: Color(0xFFB77900), size: 16),
            const SizedBox(width: 6),
            Text(_gameLabel(widget.language, 'bestCombo'), style: const TextStyle(fontSize: 9, letterSpacing: .7, color: pine, fontWeight: FontWeight.w800)),
            const SizedBox(width: 8),
            Text('x$bestComboStreak', style: const TextStyle(fontSize: 15, color: pine, fontWeight: FontWeight.w900)),
          ]),
        )),
        const SizedBox(height: 10),
        Row(
          children: List.generate(4, (slot) => Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: slot == 3 ? 0 : 8),
              child: AspectRatio(
                aspectRatio: 1,
                child: AnimatedContainer(
                  key: _slotKeys[slot],
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutBack,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .72),
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [BoxShadow(color: pine.withValues(alpha: .12), blurRadius: 12, offset: const Offset(0, 4))],
                  ),
                  child: Center(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (child, animation) => ScaleTransition(scale: CurvedAnimation(parent: animation, curve: Curves.elasticOut), child: FadeTransition(opacity: animation, child: child)),
                      child: Text(
                        storageSlots[slot] != null ? tiles[storageSlots[slot]!] : ['✦', '✧', '✦', '✧'][slot],
                        key: ValueKey('${slot}_${storageSlots[slot] ?? -1}'),
                        style: TextStyle(fontSize: storageSlots[slot] != null ? 30 : 24, color: pine, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          )),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(color: Colors.white.withValues(alpha: .72), borderRadius: BorderRadius.circular(14)),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(Icons.spa_rounded, color: leaf, size: 18),
            const SizedBox(width: 8),
            Text(finished ? _tr(widget.language, 'done') : _tr(widget.language, 'boardHelp'), style: const TextStyle(color: pine, fontWeight: FontWeight.w700)),
          ]),
        ),
        const SizedBox(height: 12),
        Expanded(child: LayoutBuilder(builder: (context, constraints) {
          // Bias toward larger touch targets on phones; the board scrolls when needed.
          final tileWidth = min((constraints.maxWidth - 8) / 8.5, (constraints.maxHeight - 8) / 6.5).clamp(44.0, 76.0).toDouble();
          final tileHeight = tileWidth;
          final boardWidth = tileWidth * 14.6;
          final boardHeight = tileHeight * 10.6;
          // The fit control scales and centers the complete board in the available viewport.
          return Stack(children: [
            InteractiveViewer(
            transformationController: _boardController,
            minScale: 0.35,
            maxScale: 2.5,
            scaleEnabled: true,
            panEnabled: true,
            constrained: false,
            alignment: Alignment.center,
            // A little more glide after lifting a finger makes panning feel less abrupt.
            interactionEndFrictionCoefficient: 0.000008,
            scaleFactor: 250,
            boundaryMargin: const EdgeInsets.all(120),
            clipBehavior: Clip.hardEdge,
            child: SizedBox(
            width: boardWidth,
            height: boardHeight,
            child: Stack(clipBehavior: Clip.none, children: List.generate(tiles.length, (i) {
              final spot = spots[i];
              final gone = removed.contains(i);
              final active = selected == i;
              final hinted = hintA == i || hintB == i;
              final wrong = mismatch == i || mismatch == selected;
              final enabled = _availableInState(i, spots, removed);
              final tileKey = _tileKeys.putIfAbsent(i, () => GlobalKey());
              return Positioned(
                left: spot.x * tileWidth * .98 + spot.layer * tileWidth * .12,
                top: (spot.y + 1) * tileHeight * .98 - spot.layer * tileHeight * .20,
                width: tileWidth,
                height: tileHeight,
                child: Transform.scale(
                  scale: gone ? .92 : active ? 1.06 : hinted ? 1.04 : 1,
                  child: Opacity(
                    opacity: gone ? 0 : enabled ? 1 : .62,
                    // Covered tiles stay visible but must not steal taps from
                    // a playable tile beneath their overlapping hit regions.
                    child: IgnorePointer(
                      ignoring: gone || !enabled,
                      child: _GardenTile(
                        key: tileKey,
                        symbol: tiles[i],
                        tileTheme: widget.tileTheme,
                        animationLevel: widget.animationLevel,
                        selected: active,
                        hinted: hinted,
                        wrong: wrong,
                        onTap: () => _tap(i),
                      ),
                    ),
                  ),
                ),
              );
            })),
            ),
          ),
          Positioned(
            right: 6,
            top: 6,
            child: LayoutBuilder(builder: (context, buttonConstraints) {
              final compact = constraints.maxWidth < 380 || constraints.maxHeight < 420;
              return Tooltip(
                message: _boardModeLabel(widget.language, _boardFitMode),
                child: Material(
                  color: cream.withValues(alpha: .96),
                  elevation: 3,
                  borderRadius: BorderRadius.circular(compact ? 10 : 12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(compact ? 10 : 12),
                    onTap: () {
                      if (_boardFitMode) {
                        setState(() => _boardFitMode = false);
                      } else {
                        setState(() => _boardFitMode = true);
                        _fitBoard(
                          constraints.maxWidth,
                          constraints.maxHeight,
                          boardWidth,
                          boardHeight,
                        );
                      }
                    },
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: compact ? 8 : 11,
                        vertical: compact ? 6 : 9,
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(
                          _boardFitMode ? Icons.zoom_in_rounded : Icons.fit_screen_rounded,
                          color: pine,
                          size: compact ? 16 : 18,
                        ),
                        if (!compact) ...[
                          const SizedBox(width: 6),
                          Text(
                            _boardModeLabel(widget.language, _boardFitMode),
                            style: const TextStyle(color: pine, fontSize: 11, fontWeight: FontWeight.w800),
                          ),
                        ],
                      ]),
                    ),
                  ),
                ),
              );
            }),
          ),
          ]);
        })),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(child: OutlinedButton.icon(
            onPressed: busy || finished ? null : () => setState(() { selected = null; hintA = null; hintB = null; }),
            icon: const Icon(Icons.close_rounded), label: Text(_tr(widget.language, 'deselect')),
          )),
          const SizedBox(width: 10),
          Expanded(child: FilledButton.icon(
            onPressed: busy || finished ? null : _shuffle,
            style: FilledButton.styleFrom(backgroundColor: pine, foregroundColor: Colors.white),
            icon: const Icon(Icons.shuffle_rounded), label: Text(_tr(widget.language, 'shuffle')),
          )),
        ]),
      ])))),
    ]),
  );
}


String _boardModeLabel(String language, bool fitMode) {
  const labels = <String, List<String>>{
    'en': ['Fit board', 'Free zoom'],
    'ru': ['Вместить поле', 'Свободный масштаб'],
    'es': ['Ajustar tablero', 'Zoom libre'],
    'fr': ['Ajuster le plateau', 'Zoom libre'],
    'de': ['Feld einpassen', 'Freier Zoom'],
    'pt': ['Enquadrar tabuleiro', 'Zoom livre'],
    'it': ['Adatta tavolo', 'Zoom libero'],
    'tr': ['Tahtayı sığdır', 'Serbest yakınlaştırma'],
    'zh': ['适应棋盘', '自由缩放'],
    'ja': ['盤面を合わせる', '自由ズーム'],
    'ko': ['보드 맞추기', '자유 확대/축소'],
    'hi': ['बोर्ड फ़िट करें', 'मुक्त ज़ूम'],
    'ar': ['ملاءمة اللوحة', 'تكبير حر'],
  };
  final pair = labels[language] ?? labels['en']!;
  return fitMode ? pair[1] : pair[0];
}

String _gameLabel(String language, String key) {
  const labels = <String, Map<String, String>>{
    'en': {'moves': 'MOVES', 'time': 'TIME', 'pairs': 'PAIRS', 'bestCombo': 'BEST COMBO'},
    'ru': {'moves': 'ХОДЫ', 'time': 'ВРЕМЯ', 'pairs': 'ПАРЫ', 'bestCombo': 'РЕКОРД КОМБО'},
    'es': {'moves': 'MOVIMIENTOS', 'time': 'TIEMPO', 'pairs': 'PAREJAS', 'bestCombo': 'MEJOR COMBO'},
    'fr': {'moves': 'COUPS', 'time': 'TEMPS', 'pairs': 'PAIRES', 'bestCombo': 'MEILLEUR COMBO'},
    'de': {'moves': 'ZÜGE', 'time': 'ZEIT', 'pairs': 'PAARE', 'bestCombo': 'BESTE KOMBINATION'},
    'pt': {'moves': 'JOGADAS', 'time': 'TEMPO', 'pairs': 'PARES', 'bestCombo': 'MELHOR COMBO'},
    'it': {'moves': 'MOSSE', 'time': 'TEMPO', 'pairs': 'COPPIE', 'bestCombo': 'MIGLIOR COMBO'},
    'tr': {'moves': 'HAMLE', 'time': 'SÜRE', 'pairs': 'ÇİFTLER', 'bestCombo': 'EN İYİ KOMBO'},
    'zh': {'moves': '步数', 'time': '时间', 'pairs': '配对', 'bestCombo': '最佳连击'},
    'ja': {'moves': '手数', 'time': '時間', 'pairs': 'ペア', 'bestCombo': '最高コンボ'},
    'ko': {'moves': '이동', 'time': '시간', 'pairs': '쌍', 'bestCombo': '최고 콤보'},
    'hi': {'moves': 'चालें', 'time': 'समय', 'pairs': 'जोड़े', 'bestCombo': 'सर्वश्रेष्ठ कॉम्बो'},
    'ar': {'moves': 'الحركات', 'time': 'الوقت', 'pairs': 'الأزواج', 'bestCombo': 'أفضل كومبو'},
  };
  return labels[language]?[key] ?? labels['en']![key]!;
}

class _GameSnapshot {
  final Set<int> removed;
  final int? selected;
  final int moves;
  final int pairs;
  final int? hintA;
  final int? hintB;
  final List<int?> storageSlots;

  const _GameSnapshot({
    required this.removed,
    required this.selected,
    required this.moves,
    required this.pairs,
    required this.hintA,
    required this.hintB,
    required this.storageSlots,
  });
}

typedef _TileSpot = TileSpot;

class _AmbientParticles extends StatefulWidget {
  final int theme;
  const _AmbientParticles({required this.theme});
  @override
  State<_AmbientParticles> createState() => _AmbientParticlesState();
}

class _AmbientParticlesState extends State<_AmbientParticles> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_AmbientDot> _dots;
  @override
  void initState() {
    super.initState();
    final random = Random(7319);
    _dots = List.generate(22, (_) => _AmbientDot(
      x: random.nextDouble(),
      y: random.nextDouble(),
      radius: 0.7 + random.nextDouble() * 1.35,
      speed: 0.012 + random.nextDouble() * 0.026,
      phase: random.nextDouble() * pi * 2,
    ));
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 18))..repeat();
  }
  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: AnimatedBuilder(
      animation: _controller,
      builder: (_, __) => CustomPaint(
        painter: _AmbientParticlePainter(_dots, _controller.value, widget.theme),
      ),
    ),
  );
  @override
  void dispose() { _controller.dispose(); super.dispose(); }
}

class _AmbientDot {
  final double x, y, radius, speed, phase;
  const _AmbientDot({required this.x, required this.y, required this.radius, required this.speed, required this.phase});
}

class _AmbientParticlePainter extends CustomPainter {
  final List<_AmbientDot> dots;
  final double progress;
  final int theme;
  const _AmbientParticlePainter(this.dots, this.progress, this.theme);
  static const _palettes = <List<Color>>[
    [Color(0xFF729B72), Color(0xFFFFD79A), Color(0xFFB5D9C2)],
    [Color(0xFFB65F8A), Color(0xFFFFC7A8), Color(0xFF9D83B9)],
    [Color(0xFF72CFC0), Color(0xFF9CCBFF), Color(0xFFC8A6F5)],
    [Color(0xFF00C9A7), Color(0xFF8A80FF), Color(0xFFFFC857)],
  ];
  @override
  void paint(Canvas canvas, Size size) {
    final palette = _palettes[theme.clamp(0, 3).toInt()];
    for (var i = 0; i < dots.length; i++) {
      final dot = dots[i];
      final drift = (progress * dot.speed * 18 + dot.y) % 1.0;
      final sway = sin(progress * pi * 2 + dot.phase) * 8;
      final twinkle = .10 + ((sin(progress * pi * 2 + dot.phase) + 1) / 2) * .16;
      final point = Offset(dot.x * size.width + sway, (1 - drift) * size.height);
      final paint = Paint()..color = palette[i % palette.length].withValues(alpha: twinkle);
      canvas.drawCircle(point, dot.radius, paint);
    }
  }
  @override
  bool shouldRepaint(covariant _AmbientParticlePainter old) => old.progress != progress || old.theme != theme;
}

class _BurstOverlay extends StatefulWidget {
  final bool intense;
  final int theme;
  final Offset center;
  const _BurstOverlay({super.key, this.intense = true, this.theme = 0, this.center = const Offset(.5, .52)});
  @override
  State<_BurstOverlay> createState() => _BurstOverlayState();
}
class _BurstOverlayState extends State<_BurstOverlay> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_Particle> _particles;
  @override
  void initState() {
    super.initState();
    final random = Random();
    _particles = List.generate(widget.intense ? 42 : 28, (_) => _Particle(
      angle: random.nextDouble() * pi * 2,
      distance: 70 + random.nextDouble() * 240,
      size: 1.8 + random.nextDouble() * (widget.intense ? 4.0 : 2.8),
      color: _palette[widget.theme.clamp(0, 3).toInt()][random.nextInt(4)],
      delay: random.nextDouble() * .16,
      spin: (random.nextDouble() - .5) * 8,
    ));
    _controller = AnimationController(vsync: this, duration: Duration(milliseconds: widget.intense ? 620 : 480))..forward();
  }
  static const _palette = <List<Color>>[
    [Color(0xFFFFD79A), Color(0xFF8FBF91), Color(0xFFB5D9C2), Colors.white],
    [Color(0xFFFF78AE), Color(0xFFFFC7A8), Color(0xFFB78AD6), Colors.white],
    [Color(0xFF72CFC0), Color(0xFF9CCBFF), Color(0xFFC8A6F5), Colors.white],
    [Color(0xFF00C9A7), Color(0xFF8A80FF), Color(0xFFFFC857), Colors.white],
  ];
  @override
  Widget build(BuildContext context) => IgnorePointer(child: AnimatedBuilder(
    animation: _controller,
    builder: (_, __) => CustomPaint(painter: _BurstPainter(_particles, _controller.value, widget.intense, widget.center)),
  ));
  @override
  void dispose() { _controller.dispose(); super.dispose(); }
}
class _Particle {
  final double angle, distance, size, delay, spin;
  final Color color;
  const _Particle({required this.angle, required this.distance, required this.size, required this.color, required this.delay, required this.spin});
}
class _BurstPainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;
  final bool intense;
  final Offset centerFraction;
  const _BurstPainter(this.particles, this.progress, this.intense, this.centerFraction);
  @override
  void paint(Canvas canvas, Size size) {
    // A compact impact burst: one fast shockwave, a brief core flash, then flying debris.
    final center = Offset(size.width * centerFraction.dx, size.height * centerFraction.dy);
    final waveProgress = Curves.easeOutCubic.transform(progress);
    final waveRadius = size.shortestSide * (.015 + waveProgress * (intense ? .20 : .14));
    final waveAlpha = ((1 - progress) * .62).clamp(0.0, 1.0).toDouble();
    canvas.drawCircle(center, waveRadius, Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = (1 - progress) * (intense ? 10 : 7) + 1
      ..color = const Color(0xFFFFE7A8).withValues(alpha: waveAlpha));
    // Short-lived hot center gives a punchy impact without washing out the whole screen.
    final flash = (1 - (progress / .18)).clamp(0.0, 1.0).toDouble();
    if (flash > 0) {
      canvas.drawCircle(center, 10 + 26 * (1 - flash), Paint()
        ..color = Colors.white.withValues(alpha: flash * .72)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12));
    }
    for (final particle in particles) {
      final local = ((progress - particle.delay) / (1 - particle.delay)).clamp(0.0, 1.0).toDouble();
      final eased = Curves.easeOutQuart.transform(local);
      final angle = particle.angle + particle.spin * local;
      final point = center + Offset(cos(angle) * particle.distance * eased, sin(angle) * particle.distance * eased + 26 * local * local);
      final alpha = ((1 - local) * (local == 0 ? 0 : 1)).clamp(0.0, 1.0).toDouble();
      final radius = particle.size * (1 - local * .62);
      final paint = Paint()..color = particle.color.withValues(alpha: alpha);
      // Angular fragments feel like a tiny impact rather than a celebratory firework.
      final tangent = Offset(-sin(angle), cos(angle));
      final radial = Offset(cos(angle), sin(angle));
      final length = radius * (intense ? 3.4 : 2.5);
      final path = Path()
        ..moveTo(point.dx + radial.dx * length, point.dy + radial.dy * length)
        ..lineTo(point.dx + tangent.dx * radius, point.dy + tangent.dy * radius)
        ..lineTo(point.dx - radial.dx * length * .7, point.dy - radial.dy * length * .7)
        ..close();
      canvas.drawPath(path, paint);
      canvas.drawCircle(point, max(.7, radius * .35), Paint()..color = Colors.white.withValues(alpha: alpha * .7));
    }
  }
  @override
  bool shouldRepaint(covariant _BurstPainter old) => old.progress != progress || old.centerFraction != centerFraction;
}

class _TileArtworkPainter extends CustomPainter {
  final int seed;
  final int theme;
  final bool highlighted;
  const _TileArtworkPainter({required this.seed, required this.theme, required this.highlighted});

  @override
  void paint(Canvas canvas, Size size) {
    final palettes = <List<Color>>[
      [const Color(0xFF47765D), const Color(0xFF9DBD76), const Color(0xFFE2B16B), const Color(0xFFD98770)],
      [const Color(0xFFC14F83), const Color(0xFFEC8D9E), const Color(0xFFFFC96B), const Color(0xFF7656A8)],
      [const Color(0xFF247F88), const Color(0xFF64C9B8), const Color(0xFF7C8FE8), const Color(0xFFE8C56B)],
      [const Color(0xFFB8C8FF), const Color(0xFF8D79E6), const Color(0xFF5CE0D0), const Color(0xFFFFD479)],
    ];
    final colors = palettes[theme.clamp(0, 3).toInt()];
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide * .37;
    final paint = Paint()..style = PaintingStyle.stroke..strokeWidth = 1.8..strokeCap = StrokeCap.round;
    final fill = Paint()..style = PaintingStyle.fill;
    final dark = colors[seed.abs() % colors.length];
    final accent = colors[(seed.abs() + 1) % colors.length];
    final secondary = colors[(seed.abs() + 2) % colors.length];
    // A small illustrated medallion: layered rings, hand-drawn petals, and a stem.
    paint.color = dark.withValues(alpha: .9);
    canvas.drawCircle(center, radius, paint);
    paint
      ..color = accent.withValues(alpha: .85)
      ..strokeWidth = 1.35;
    canvas.drawCircle(center, radius * .76, paint);
    final petals = 4 + seed.abs() % 7;
    final motif = seed.abs() % 3;
    for (var i = 0; i < petals; i++) {
      final angle = (pi * 2 * i / petals) + (seed % 11) * .04;
      final distance = radius * (.42 + (motif * .035));
      final petalCenter = center + Offset(cos(angle) * distance, sin(angle) * distance);
      fill.color = (i.isEven ? accent : secondary).withValues(alpha: .88);
      final petalWidth = radius * (.36 + ((seed + i).abs() % 4) * .055);
      final petalHeight = radius * (.22 + ((seed + i * 3).abs() % 3) * .045);
      canvas.drawOval(Rect.fromCenter(center: petalCenter, width: petalWidth, height: petalHeight).shift(Offset(cos(angle) * 1.2, sin(angle) * 1.2)), fill);
    }
    fill.color = highlighted ? const Color(0xFFFFF0B4) : colors[3];
    canvas.drawCircle(center, radius * .22, fill);
    paint
      ..color = dark
      ..strokeWidth = 1.5;
    final stem = Path()
      ..moveTo(center.dx, center.dy + radius * .22)
      ..quadraticBezierTo(center.dx - radius * .12, center.dy + radius * .65, center.dx + radius * .06, size.height - 2);
    canvas.drawPath(stem, paint);
    for (var side = -1; side <= 1; side += 2) {
      final y = center.dy + radius * (.48 + (side == 1 ? .25 : 0));
      final leafPath = Path()
        ..moveTo(center.dx, y)
        ..quadraticBezierTo(center.dx + side * radius * .65, y - radius * .5, center.dx + side * radius * .75, y + radius * .05)
        ..quadraticBezierTo(center.dx + side * radius * .35, y + radius * .35, center.dx, y)
        ..close();
      fill.color = secondary.withValues(alpha: .92);
      canvas.drawPath(leafPath, fill);
    }
    if (highlighted) {
      paint..color = const Color(0xFFFFD479)..strokeWidth = 1.2;
      canvas.drawCircle(center, radius + 2.2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _TileArtworkPainter oldDelegate) =>
      oldDelegate.seed != seed || oldDelegate.theme != theme || oldDelegate.highlighted != highlighted;
}

class _GardenTile extends StatelessWidget {
  final String symbol;
  final int tileTheme;
  final int animationLevel;
  final bool selected;
  final bool hinted;
  final bool wrong;
  final VoidCallback onTap;
  const _GardenTile({super.key, required this.symbol, this.tileTheme = 0, this.animationLevel = 2, required this.selected, required this.hinted, required this.wrong, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final tileColors = _GameScreenState._tileColors[tileTheme.clamp(0, 3).toInt()];
    final borderColor = wrong
        ? const Color(0xFFD77B66)
        : selected
            ? const Color(0xFFD58D59)
            : hinted
                ? const Color(0xFF6F9E78)
                : const Color(0xFFD5DFC9);
    return Container(
      decoration: BoxDecoration(
        color: selected ? tileColors[1] : tileColors[0],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor, width: selected || hinted || wrong ? 2.5 : 1),
        boxShadow: selected || hinted || wrong ? [BoxShadow(color: pine.withValues(alpha: .18), blurRadius: 8, offset: const Offset(0, 3))] : const [],
      ),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Stack(children: [
            Positioned(top: 5, left: 5, child: Icon(Icons.circle, size: 4, color: borderColor.withValues(alpha: .7))),
            Positioned(bottom: 5, right: 5, child: Icon(Icons.circle, size: 4, color: borderColor.withValues(alpha: .7))),
            Center(child: SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CustomPaint(
                      painter: _TileArtworkPainter(seed: symbol.hashCode, theme: tileTheme, highlighted: selected || hinted),
                    ),
                    Center(
                      child: Text(
                        symbol,
                        style: const TextStyle(fontSize: 30, height: 1.0),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              )),
            if (hinted)
              const Positioned(right: 5, top: 4, child: Icon(Icons.auto_awesome_rounded, size: 14, color: leaf)),
          ]),
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String label;
  final String value;
  const _StatPill({required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10), decoration: BoxDecoration(color: Colors.white.withValues(alpha: .8), borderRadius: BorderRadius.circular(15)), child: Column(children: [Text(label, style: const TextStyle(fontSize: 9, letterSpacing: 1, color: pine, fontWeight: FontWeight.w800)), Text(value, style: const TextStyle(fontSize: 19, color: pine, fontWeight: FontWeight.w900))]));
}

class _ModeCard extends StatelessWidget {
  final IconData icon; final String title; final String subtitle; final Color color; final VoidCallback onTap;
  const _ModeCard({required this.icon, required this.title, required this.subtitle, required this.color, required this.onTap});
  @override
  Widget build(BuildContext context) => Material(color: color, borderRadius: BorderRadius.circular(22), child: InkWell(borderRadius: BorderRadius.circular(22), onTap: onTap, child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(icon, color: pine, size: 25), const SizedBox(height: 18), Text(title, style: const TextStyle(fontWeight: FontWeight.w900, color: pine, fontSize: 16)), const SizedBox(height: 4), Text(subtitle, style: TextStyle(color: pine.withValues(alpha: .75), fontSize: 11, height: 1.3))]))));
}

class _WideAction extends StatelessWidget {
  final IconData icon; final String title; final String subtitle; final VoidCallback onTap;
  const _WideAction({required this.icon, required this.title, required this.subtitle, required this.onTap});
  @override
  Widget build(BuildContext context) => Material(color: Colors.white.withValues(alpha: .82), borderRadius: BorderRadius.circular(18), child: InkWell(borderRadius: BorderRadius.circular(18), onTap: onTap, child: Padding(padding: const EdgeInsets.all(15), child: Row(children: [Container(width: 43, height: 43, decoration: BoxDecoration(color: const Color(0xFFE1EBD9), borderRadius: BorderRadius.circular(14)), child: Icon(icon, color: pine)), const SizedBox(width: 13), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(color: pine, fontWeight: FontWeight.w900)), const SizedBox(height: 3), Text(subtitle, style: TextStyle(color: pine.withValues(alpha: .7), fontSize: 12))])), const Icon(Icons.chevron_right_rounded, color: pine)]))));
}

class _TileShowcase extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final data = [('🍃', const Color(0xFFE3EDD9)), ('🌼', const Color(0xFFFFE7AF)), ('🍄', const Color(0xFFF6D8C8)), ('🦋', const Color(0xFFD9E8EF))];
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: data.map((e) => Transform.rotate(angle: (data.indexOf(e) - 1.5) * .07, child: Container(margin: const EdgeInsets.symmetric(horizontal: 4), width: 61, height: 72, decoration: BoxDecoration(color: e.$2, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.white, width: 2), boxShadow: [BoxShadow(color: pine.withValues(alpha: .12), blurRadius: 8, offset: const Offset(0, 5))]), child: Center(child: Text(e.$1, style: const TextStyle(fontSize: 27)))))).toList());
  }
}

class NatureBackdrop extends StatelessWidget {
  final int theme;
  const NatureBackdrop({super.key, this.theme = 0});
  static const _gradients = [
    [Color(0xFFE8F0DE), Color(0xFFFFF6E7), Color(0xFFF8E3CD)],
    [Color(0xFFFFD6E8), Color(0xFFFFE7A8), Color(0xFFFFA6A6)],
    [Color(0xFFB8F2E6), Color(0xFFBDE0FE), Color(0xFFCDB4DB)],
    [Color(0xFF171B45), Color(0xFF302B63), Color(0xFF24243E)],
  ];
  @override
  Widget build(BuildContext context) => Stack(fit: StackFit.expand, children: [
    DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: _gradients[theme.clamp(0, 3).toInt()]))),
    Positioned(top: 120, right: -65, child: _Sun()),
    Positioned(bottom: -95, left: -65, child: _Hill(width: 310, height: 250, color: const Color(0xFFC7D9B5))),
    Positioned(bottom: -115, right: -45, child: _Hill(width: 330, height: 260, color: const Color(0xFF9EBB91))),
    Positioned(bottom: -145, left: 80, child: _Hill(width: 340, height: 260, color: const Color(0xFF7F9F7A))),
  ]);
}

class _Sun extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(width: 150, height: 150, decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFFFFD9A1).withValues(alpha: .6)));
}
class _Hill extends StatelessWidget {
  final double width; final double height; final Color color;
  const _Hill({required this.width, required this.height, required this.color});
  @override
  Widget build(BuildContext context) => Container(width: width, height: height, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.all(Radius.elliptical(width, height))));
}
