/// Utility functions for handling Ethereum-style addresses
class AddressUtils {
  /// Truncates an Ethereum address to show first 6 and last 4 characters
  /// Example: "0x1234567890abcdef1234567890abcdef12345678" -> "0x1234...5678"
  static String truncateAddress(String address) {
    if (address.length <= 10) {
      return address;
    }
    
    // Remove 0x prefix if present for calculation
    final cleanAddress = address.startsWith('0x') ? address.substring(2) : address;
    
    if (cleanAddress.length <= 8) {
      return address;
    }
    
    // Take first 4 and last 4 characters
    final firstPart = cleanAddress.substring(0, 4);
    final lastPart = cleanAddress.substring(cleanAddress.length - 4);
    
    return '0x$firstPart...$lastPart';
  }
  
  /// Validates if a string looks like an Ethereum address
  static bool isValidAddress(String address) {
    // Basic validation - should start with 0x and be 42 characters total
    if (!address.startsWith('0x')) {
      return false;
    }
    
    final cleanAddress = address.substring(2);
    return cleanAddress.length == 40 && RegExp(r'^[0-9a-fA-F]+$').hasMatch(cleanAddress);
  }
  
  /// Generates initials from an address (first 2 characters after 0x)
  static String getAddressInitials(String address) {
    if (address.length < 4) {
      return address.toUpperCase();
    }
    
    final cleanAddress = address.startsWith('0x') ? address.substring(2) : address;
    return cleanAddress.substring(0, 2).toUpperCase();
  }
  
  /// Checks if a string looks like an address that should be truncated
  /// This includes Ethereum addresses and Nostr public keys (long hex strings)
  static bool isAddressLike(String text) {
    // Check if it's a valid Ethereum address
    if (isValidAddress(text)) {
      return true;
    }
    
    // Check if it's a long hexadecimal string (like Nostr public keys)
    // Nostr public keys are typically 64 characters long
    if (text.length >= 40 && RegExp(r'^[0-9a-fA-F]+$').hasMatch(text)) {
      return true;
    }
    
    return false;
  }
  
  /// Truncates a username if it's actually an address, otherwise returns the original
  static String truncateIfAddress(String text) {
    if (isAddressLike(text)) {
      return truncateAddress(text);
    }
    return text;
  }
}
