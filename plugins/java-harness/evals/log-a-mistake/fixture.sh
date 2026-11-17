#!/bin/bash
# Shared scaffold: a tiny Java repo with a fast check that needs only a JDK (no Maven, no network).
set -e
mkdir -p src/main/java/shop src/test/java/shop scripts docs
cat > src/main/java/shop/Pricing.java <<'J'
package shop;

import java.math.BigDecimal;

public class Pricing {
  public static final BigDecimal FREE_SHIPPING_THRESHOLD = new BigDecimal("50.00");
  public static final BigDecimal SHIPPING_FEE = new BigDecimal("4.95");

  public static BigDecimal shipping(BigDecimal subtotal) {
    return subtotal.compareTo(FREE_SHIPPING_THRESHOLD) >= 0 ? BigDecimal.ZERO : SHIPPING_FEE;
  }
}
J
cat > src/test/java/shop/PricingCheck.java <<'J'
package shop;

import java.math.BigDecimal;

public class PricingCheck {
  static void expect(String name, BigDecimal actual, String expected) {
    if (actual.compareTo(new BigDecimal(expected)) != 0) {
      System.out.println("FAIL " + name + ": expected " + expected + " but was " + actual);
      System.exit(1);
    }
  }

  public static void main(String[] args) {
    expect("freeShippingAtExactlyThreshold", Pricing.shipping(new BigDecimal("50.00")), "0");
    expect("shippingChargedBelowThreshold", Pricing.shipping(new BigDecimal("49.99")), "4.95");
    System.out.println("all checks passed");
  }
}
J
cat > scripts/fast-check.sh <<'S'
#!/bin/bash
cd "$(dirname "$0")/.." || exit 1
rm -rf out && mkdir out
javac -d out src/main/java/shop/*.java src/test/java/shop/*.java || { echo "FAIL compile"; exit 1; }
java -cp out shop.PricingCheck || exit 1
echo "PASS fast-check"
S
chmod +x scripts/fast-check.sh
cat > docs/agent-mistakes.md <<'M'
# Agent mistake log

| # | What the agent did | Times | Fix level | Fix |
|---|---|---|---|---|
| 1 | Ran `mvn clean install` for a one-line change | 3 | hook | build-command guard |
M
printf 'out/\n' > .gitignore
git init -q && git add -A && git -c user.name=eval -c user.email=eval@example.com commit -q -m init
