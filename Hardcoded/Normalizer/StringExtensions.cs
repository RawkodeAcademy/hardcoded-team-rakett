using System.Globalization;
using System.Text;

namespace Normalizer;

public static class StringExtensions
{
    public static string RemoveDiacritics(this string text)
    {
        if (string.IsNullOrWhiteSpace(text))
        {
            return text;
        }

        // Normalize the string to Unicode Normalization Form D (NFD).
        // In NFD, accented characters are decomposed into a base character and combining diacritical marks.
        string normalizedString = text.Normalize(NormalizationForm.FormD);
        StringBuilder stringBuilder = new StringBuilder();

        foreach (char c in normalizedString)
        {
            // Get the Unicode category of the character.
            // NonSpacingMark indicates a diacritical mark.
            if (CharUnicodeInfo.GetUnicodeCategory(c) != UnicodeCategory.NonSpacingMark)
            {
                stringBuilder.Append(c);
            }
        }

        // Re-normalize the string to Unicode Normalization Form C (NFC)
        // to combine any characters that were separated but are not diacritics.
        return stringBuilder.ToString().Normalize(NormalizationForm.FormC);
    }
}