/// Result of parsing an ERC20 transfer from nested calldata
class ERC20Transfer {
  final String recipient;
  final BigInt amount;
  final String tokenAddress;

  ERC20Transfer({
    required this.recipient,
    required this.amount,
    required this.tokenAddress,
  });

  @override
  String toString() {
    return 'ERC20Transfer(recipient: $recipient, amount: $amount, tokenAddress: $tokenAddress)';
  }
}

/// Parses an ERC20 transfer from calldata nested inside execTransactionFromModule
///
/// Expected format:
/// - Outer function: execTransactionFromModule(address,uint256,bytes,uint8)
/// - Inner function (in bytes): transfer(address,uint256)
///
/// Returns the recipient address and amount, along with the token address from outer function
ERC20Transfer? parseNestedERC20Transfer(String calldata) {
  try {
    print('Parsing nested ERC20 transfer from calldata: $calldata');
    // Remove 0x prefix if present
    String data = calldata.startsWith('0x') ? calldata.substring(2) : calldata;

    // Check function selector for execTransactionFromModule (0x468721a7)
    if (!data.startsWith('468721a7')) {
      throw Exception(
        'Invalid function selector. Expected execTransactionFromModule (0x468721a7)',
      );
    }

    // Skip function selector (8 chars)
    int offset = 8;

    // Read token address (first parameter - address, 32 bytes = 64 hex chars)
    String tokenAddress = '0x' + data.substring(offset + 24, offset + 64);
    offset += 64;

    // Skip uint256 value parameter (32 bytes)
    offset += 64;

    // Read bytes offset (32 bytes) - should point to where bytes data starts
    String bytesOffsetHex = data.substring(offset, offset + 64);
    int bytesOffset = int.parse(bytesOffsetHex, radix: 16);
    offset += 64;

    // Skip uint8 operation parameter (32 bytes)
    offset += 64;

    // Jump to bytes data location (bytesOffset * 2 because we're counting hex chars)
    // bytesOffset is in bytes, but we need chars, so multiply by 2
    // Also add 8 for the function selector we already skipped
    int bytesDataStart = 8 + (bytesOffset * 2);

    // Read length of bytes data (32 bytes)
    String bytesLengthHex = data.substring(bytesDataStart, bytesDataStart + 64);
    int bytesLength = int.parse(bytesLengthHex, radix: 16);
    bytesDataStart += 64;

    // Extract the inner calldata (transfer function)
    String transferCalldata = data.substring(
      bytesDataStart,
      bytesDataStart + (bytesLength * 2),
    );

    // Check function selector for transfer (0xa9059cbb)
    if (!transferCalldata.startsWith('a9059cbb')) {
      throw Exception(
        'Invalid inner function selector. Expected transfer (0xa9059cbb)',
      );
    }

    // Parse transfer parameters
    int transferOffset = 8; // Skip function selector

    // Read recipient address (32 bytes)
    String recipient =
        '0x' +
        transferCalldata.substring(transferOffset + 24, transferOffset + 64);
    transferOffset += 64;

    // Read amount (32 bytes)
    String amountHex = transferCalldata.substring(
      transferOffset,
      transferOffset + 64,
    );
    BigInt amount = BigInt.parse(amountHex, radix: 16);

    return ERC20Transfer(
      recipient: recipient,
      amount: amount,
      tokenAddress: tokenAddress,
    );
  } catch (e) {
    print('Error parsing calldata: $e');
    return null;
  }
}
