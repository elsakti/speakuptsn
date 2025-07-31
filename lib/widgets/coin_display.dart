import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CoinDisplay extends StatelessWidget {
  final int coins;
  final bool isCompact;

  const CoinDisplay({
    super.key,
    required this.coins,
    this.isCompact = true,
  });

  @override
  Widget build(BuildContext context) {
    final coinText = _formatCoins(coins);
    
    if (isCompact) {
      return IntrinsicWidth(
        child: Container(
          constraints: const BoxConstraints(minWidth: 50),
          padding: EdgeInsets.symmetric(
            horizontal: _getHorizontalPadding(coinText, true),
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFF860092),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.account_balance_wallet_rounded,
                color: Colors.white,
                size: 14,
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  coinText,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return IntrinsicWidth(
      child: Container(
        constraints: const BoxConstraints(minWidth: 80),
        padding: EdgeInsets.symmetric(
          horizontal: _getHorizontalPadding(coinText, false),
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF860092),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF860092).withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_balance_wallet_rounded,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                coinText,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              'Coins',
              style: GoogleFonts.inter(
                color: Colors.white.withOpacity(0.9),
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _getHorizontalPadding(String coinText, bool isCompact) {
    final length = coinText.length;
    if (isCompact) {
      if (length <= 3) return 12;
      if (length <= 5) return 10;
      return 8;
    } else {
      if (length <= 3) return 16;
      if (length <= 5) return 14;
      return 12;
    }
  }

  String _formatCoins(int coins) {
    if (coins >= 1000000) {
      double millions = coins / 1000000;
      if (millions >= 10) {
        return '${millions.toStringAsFixed(0)}M';
      }
      return '${millions.toStringAsFixed(1)}M';
    } else if (coins >= 1000) {
      double thousands = coins / 1000;
      if (thousands >= 10) {
        return '${thousands.toStringAsFixed(0)}K';
      }
      return '${thousands.toStringAsFixed(1)}K';
    }
    return coins.toString();
  }
}
