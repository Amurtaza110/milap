// import 'dart:async';
// import 'package:flutter/material.dart';
// import '../models/user_profile.dart';
// import '../theme/app_colors.dart';
// import '../theme/app_text_styles.dart';
// import '../theme/app_button_styles.dart';
//
// class LiveStreamingScreen extends StatefulWidget {
//   final UserProfile user;
//   final VoidCallback onClose;
//
//   const LiveStreamingScreen({
//     Key? key,
//     required this.user,
//     required this.onClose,
//   }) : super(key: key);
//
//   @override
//   State<LiveStreamingScreen> createState() => _LiveStreamingScreenState();
// }
//
// class _LiveStreamingScreenState extends State<LiveStreamingScreen> {
//   final List<Map<String, String>> _comments = [];
//   int _viewerCount = 0;
//   Timer? _timer;
//   final _commentController = TextEditingController();
//
//   @override
//   void initState() {
//     super.initState();
//     if (widget.user.isMilapGold && widget.user.rating >= 4.5) {
//       _startSimulation();
//     }
//   }
//
//   void _startSimulation() {
//     _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
//       if (mounted) {
//         setState(() {
//           _viewerCount += (timer.tick % 5);
//           if (timer.tick % 3 == 0) {
//             _comments.add(
//                 {'name': 'User${timer.tick}', 'text': 'Looking great! 🔥'});
//             if (_comments.length > 15) _comments.removeAt(0);
//           }
//         });
//       }
//     });
//   }
//
//   @override
//   void dispose() {
//     _timer?.cancel();
//     _commentController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final isEligible = widget.user.isMilapGold && widget.user.rating >= 4.5;
//
//     if (!isEligible) return _buildAccessDenied();
//
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: Stack(
//         children: [
//           // Background "Video" (Placeholder)
//           Positioned.fill(
//               child: Image.network('https://picsum.photos/1080/1920',
//                   fit: BoxFit.cover,
//                   opacity: const AlwaysStoppedAnimation(0.7))),
//           Container(
//               decoration: const BoxDecoration(
//                   gradient: LinearGradient(
//                       begin: Alignment.topCenter,
//                       end: Alignment.bottomCenter,
//                       colors: [
//                 Colors.black54,
//                 Colors.transparent,
//                 Colors.black87
//               ]))),
//
//           // Top Controls
//           Positioned(
//             top: 64,
//             left: 24,
//             right: 24,
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Container(
//                   padding: const EdgeInsets.all(4),
//                   decoration: BoxDecoration(
//                       color: Colors.black45,
//                       borderRadius: BorderRadius.circular(30),
//                       border: Border.all(color: Colors.white10)),
//                   child: Row(
//                     children: [
//                       CircleAvatar(
//                           backgroundImage: NetworkImage(widget.user.photos[0]),
//                           radius: 16),
//                       const SizedBox(width: 8),
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(widget.user.name.toUpperCase(),
//                               style: AppTextStyles.label.copyWith(
//                                   color: Colors.white,
//                                   fontSize: 10,
//                                   fontWeight: FontWeight.w900,
//                                   letterSpacing: 1.0)),
//                           Row(children: [
//                             Container(
//                                 width: 6,
//                                 height: 6,
//                                 decoration: const BoxDecoration(
//                                     color: Colors.red, shape: BoxShape.circle)),
//                             const SizedBox(width: 4),
//                             Text('LIVE',
//                                 style: AppTextStyles.label.copyWith(
//                                     color: Colors.white70,
//                                     fontSize: 8,
//                                     fontWeight: FontWeight.bold))
//                           ]),
//                         ],
//                       ),
//                       const SizedBox(width: 12),
//                     ],
//                   ),
//                 ),
//                 Container(
//                     padding:
//                         const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                     decoration: BoxDecoration(
//                         color: Colors.black45,
//                         borderRadius: BorderRadius.circular(12),
//                         border: Border.all(color: Colors.white10)),
//                     child: Row(children: [
//                       const Icon(Icons.remove_red_eye_rounded,
//                           size: 14, color: Colors.white),
//                       const SizedBox(width: 6),
//                       Text('$_viewerCount',
//                           style: AppTextStyles.label.copyWith(
//                               color: Colors.white,
//                               fontSize: 10,
//                               fontWeight: FontWeight.w900))
//                     ])),
//                 IconButton(
//                     onPressed: widget.onClose,
//                     icon: const Icon(Icons.close, color: Colors.white)),
//               ],
//             ),
//           ),
//
//           // Comments Section
//           Positioned(
//             bottom: 120,
//             left: 24,
//             right: 24,
//             height: 200,
//             child: ListView.builder(
//               reverse: true,
//               itemCount: _comments.length,
//               itemBuilder: (context, index) {
//                 final c = _comments[_comments.length - 1 - index];
//                 return Padding(
//                   padding: const EdgeInsets.only(bottom: 8),
//                   child: Row(
//                     children: [
//                       Container(
//                           padding: const EdgeInsets.symmetric(
//                               horizontal: 12, vertical: 6),
//                           decoration: BoxDecoration(
//                               color: Colors.black38,
//                               borderRadius: BorderRadius.circular(12)),
//                           child: RichText(
//                               text: TextSpan(children: [
//                             TextSpan(
//                                 text: '${c['name']} ',
//                                 style: AppTextStyles.label.copyWith(
//                                     color: Colors.white70,
//                                     fontSize: 10,
//                                     fontWeight: FontWeight.w900)),
//                             TextSpan(
//                                 text: c['text'],
//                                 style: AppTextStyles.body.copyWith(
//                                     color: Colors.white,
//                                     fontSize: 12,
//                                     fontWeight: FontWeight.w500))
//                           ]))),
//                     ],
//                   ),
//                 );
//               },
//             ),
//           ),
//
//           // Bottom Bar
//           Positioned(
//             bottom: 40,
//             left: 24,
//             right: 24,
//             child: Row(
//               children: [
//                 Expanded(
//                     child: TextField(
//                         controller: _commentController,
//                         style:
//                             const TextStyle(color: Colors.white, fontSize: 14),
//                         decoration: InputDecoration(
//                             hintText: 'Say something...',
//                             hintStyle: const TextStyle(
//                                 color: Colors.white54, fontSize: 14),
//                             filled: true,
//                             fillColor: Colors.black45,
//                             border: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(30),
//                                 borderSide: BorderSide.none),
//                             contentPadding: const EdgeInsets.symmetric(
//                                 horizontal: 20, vertical: 12)))),
//                 const SizedBox(width: 12),
//                 Container(
//                     width: 48,
//                     height: 48,
//                     decoration: const BoxDecoration(
//                         color: AppColors.primary, shape: BoxShape.circle),
//                     child: const Icon(Icons.favorite, color: Colors.white)),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildAccessDenied() {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: Center(
//         child: Padding(
//           padding: const EdgeInsets.all(48),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Container(
//                   width: 100,
//                   height: 100,
//                   decoration: BoxDecoration(
//                       color: Colors.white10,
//                       shape: BoxShape.circle,
//                       border: Border.all(color: Colors.white24)),
//                   child: const Icon(Icons.lock_rounded,
//                       color: Colors.white30, size: 40)),
//               const SizedBox(height: 32),
//               Text('ACCESS DENIED',
//                   style: AppTextStyles.h2.copyWith(
//                       color: Colors.white, fontSize: 24, letterSpacing: 2.0)),
//               const SizedBox(height: 16),
//               Text(
//                   'Milap Live is exclusive to Gold Members with a 4.5+ rating.',
//                   textAlign: TextAlign.center,
//                   style: AppTextStyles.body.copyWith(
//                       color: Colors.white54,
//                       fontSize: 12,
//                       fontWeight: FontWeight.w500)),
//               const SizedBox(height: 48),
//               ElevatedButton(
//                   onPressed: widget.onClose,
//                   style: AppButtonStyles.primary,
//                   child: const Text('BACK TO SAFETY')),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
