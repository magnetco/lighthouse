# Submit for Review

**Category:** App Store
**Priority:** P0 Critical
**Effort:** XS
**Status:** Not Started

## Summary

Submit the completed Lighthouse app to Apple for review. This is the final step before the app can be published to the Mac App Store. Apple typically reviews Mac apps within 24-48 hours.

## Acceptance Criteria

- [ ] All required metadata complete
- [ ] Build selected for submission
- [ ] Review notes added (if needed)
- [ ] App submitted successfully
- [ ] Confirmation email received
- [ ] Status shows "Waiting for Review"

## Technical Notes

### Pre-Submission Checklist

Before clicking "Submit for Review":

**App Information**
- [ ] App name is correct
- [ ] Bundle ID matches uploaded build
- [ ] Version and build number correct

**Metadata**
- [ ] Description complete and accurate
- [ ] Keywords set
- [ ] Categories selected
- [ ] Screenshots uploaded (all sizes)
- [ ] App icon displays correctly

**URLs**
- [ ] Privacy Policy URL works and loads
- [ ] Support URL works and loads

**Build**
- [ ] Build uploaded and processed
- [ ] Build selected in "Build" section
- [ ] No "Missing Compliance" warnings

**Legal**
- [ ] Age rating questionnaire complete
- [ ] Copyright set
- [ ] EULA accepted (or custom EULA uploaded)

### Review Notes

Add notes for the App Review team if needed:

```
Lighthouse monitors local TCP services using macOS's built-in lsof 
utility, manages Docker containers via the Docker CLI (if installed), 
and performs HTTP HEAD requests to monitor website availability.

All features work offline except website monitoring. No user data is 
collected or transmitted.

Docker integration is optional - the app works fully without Docker 
installed.
```

### App Review Guidelines Compliance

Lighthouse should pass review because:

| Guideline | Status |
|-----------|--------|
| 1.1 Safety | ✅ No objectionable content |
| 2.1 Performance | ✅ Stable, no crashes |
| 2.3 Accurate Metadata | ✅ Description matches functionality |
| 3.1 Payments | ✅ No IAP issues |
| 4.0 Design | ✅ Native macOS design |
| 5.1 Privacy | ✅ No data collection |

### Submission Steps

1. **Go to App Store Connect**
   - [appstoreconnect.apple.com](https://appstoreconnect.apple.com)

2. **Select Your App**
   - Click on Lighthouse

3. **Navigate to Version**
   - App Store tab > macOS App > Version 1.0.0

4. **Review All Sections**
   - Scroll through and verify everything

5. **Add Build**
   - In "Build" section, click "+" and select your uploaded build

6. **Submit**
   - Click "Add for Review" or "Submit for Review"
   - Confirm submission

### After Submission

- Status changes to "Waiting for Review"
- Apple emails confirmation
- Review typically takes 24-48 hours
- You'll get email notification of result

### If Rejected

Common rejection reasons and fixes:

| Rejection | Fix |
|-----------|-----|
| "Guideline 2.1 - Crashes" | Test more, fix bugs, resubmit |
| "Guideline 2.3 - Metadata" | Update description to match features |
| "Guideline 5.1.1 - Privacy" | Add privacy manifest or update policy |
| "Missing functionality" | Ensure all features work, add demo data |

To respond to rejection:
1. Read rejection message carefully
2. Make necessary fixes
3. Increment build number
4. Upload new build
5. Resubmit for review

### Timeline

| Stage | Duration |
|-------|----------|
| Submit | Instant |
| Waiting for Review | 0-24 hours |
| In Review | 1-24 hours |
| Approved/Rejected | Instant notification |
| Processing for Sale | 0-24 hours |
| Available on Store | After processing |

## Dependencies

- [04-archive-and-upload](04-archive-and-upload.md) - Build must be uploaded
- [05-app-store-listing](05-app-store-listing.md) - Listing must be complete

## Resources

- [App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)
- [Common App Rejections](https://developer.apple.com/app-store/review/rejections/)
- [App Store Connect Help](https://developer.apple.com/help/app-store-connect/)
