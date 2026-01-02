# SSIS Connection Tips - Understanding Output Arrows

## Understanding Output Arrows in SSIS

When you add a data source component (Flat File Source, Excel Source, OLE DB Source) in SSIS, you'll see **two output arrows**:

### 🔵 BLUE Arrow (Left Side) - Default Output
- **This is the one you use for normal data flow**
- Contains the actual data rows
- Connect this to transformations and destinations
- **Always use the BLUE arrow for your data connections**

### 🔴 RED/ORANGE Arrow (Right Side) - Error Output
- Used for error handling
- Contains rows that failed validation or had errors
- You can connect this to error logging destinations
- **Ignore this for basic connections** (you can set it up later for error handling)

## How to Connect Components

### Step-by-Step Connection Process:

1. **Click on the BLUE arrow** of the source component
2. **Drag** to the target component (transformation or destination)
3. A **connection line** will appear
4. The line will be **blue** if the connection is valid

### Visual Guide:
```
[Source Component]
    🔵 ← Click and drag from here
    🔴 ← Ignore this (error output)
         ↓
    [Target Component]
```

## Merge Join Configuration

### Understanding Left vs Right Input

When configuring a **Merge Join** transformation:

#### Left Input
- The **first** data source you connect
- In a **Left Outer Join**, this is the table where you want to **keep ALL rows**
- Usually your **main/primary table** (e.g., Transactions)
- Example: `FF_Source_Transactions` → Left Input

#### Right Input
- The **second** data source you connect
- In a **Left Outer Join**, this is the **lookup/reference table**
- Rows from this table are matched and joined to the left input
- Example: `OLE_Source_Products` → Right Input

### Example Scenario:

**Transactions (Left) + Products (Right)**
- Left Input = Transactions (keep all transactions)
- Right Input = Products (lookup product details)
- Join on: ProductID = ProductID
- Result: All transactions with their product details (if product exists)

**If ProductID doesn't exist in Products table:**
- With Left Outer Join: Transaction still appears, but ProductName and Price will be NULL
- With Inner Join: Transaction would be excluded

## Connection Order Matters

The **order you connect** determines which is Left and which is Right:

1. **First connection** → Becomes **Left Input**
2. **Second connection** → Becomes **Right Input**

You can change this in the Merge Join editor if needed.

## Common Mistakes to Avoid

❌ **Don't connect the RED arrow** for normal data flow
✅ **Always use the BLUE arrow** for data connections

❌ **Don't connect both inputs from the same source**
✅ **Connect from different sources** (e.g., Transactions + Products)

❌ **Don't forget to configure the join key**
✅ **Always specify which columns to join on** (e.g., ProductID = ProductID)

## Quick Reference

| Component | Blue Arrow | Red Arrow |
|-----------|-----------|-----------|
| Flat File Source | ✅ Use this | ❌ Error output |
| Excel Source | ✅ Use this | ❌ Error output |
| OLE DB Source | ✅ Use this | ❌ Error output |
| Transformations | ✅ Use this | ❌ Error output |
| Destinations | ✅ Use this | ❌ Error output |

---

**Remember**: Blue = Data, Red = Errors. Always connect the blue arrows for your data flow!

