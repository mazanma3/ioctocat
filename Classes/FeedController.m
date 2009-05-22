#import "FeedController.h"
#import "FeedEntryController.h"


@implementation FeedController

- (id)initWithFeed:(GHFeed *)theFeed andTitle:(NSString *)theTitle {
	[super initWithNibName:@"Feed" bundle:nil];
	self.title = theTitle;
	recentCommits = [theFeed retain];
	[recentCommits addObserver:self forKeyPath:kResourceStatusKeyPath options:NSKeyValueObservingOptionNew context:nil];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	if (!recentCommits.isLoaded) [recentCommits loadEntries];
}

- (void)dealloc {
	[recentCommits removeObserver:self forKeyPath:kResourceStatusKeyPath];
    [loadingRecentCommitsCell release];
	[noRecentCommitsCell release];
	[feedEntryCell release];
	[recentCommits release];
    [super dealloc];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:object change:change context:context {
	if ([keyPath isEqualToString:kResourceStatusKeyPath]) [self.tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return (recentCommits.isLoading || recentCommits.entries.count == 0) ? 1 : recentCommits.entries.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (!recentCommits.isLoaded) return loadingRecentCommitsCell;
	if (recentCommits.entries.count == 0) return noRecentCommitsCell;
	FeedEntryCell *cell = (FeedEntryCell *)[tableView dequeueReusableCellWithIdentifier:kFeedEntryCellIdentifier];
	if (cell == nil) {
		[[NSBundle mainBundle] loadNibNamed:@"FeedEntryCell" owner:self options:nil];
		cell = feedEntryCell;
	}
	cell.entry = [recentCommits.entries objectAtIndex:indexPath.row];
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (recentCommits.entries.count == 0) return;
	GHFeedEntry *entry = [recentCommits.entries objectAtIndex:indexPath.row];
	FeedEntryController *entryController = [[FeedEntryController alloc] initWithFeedEntry:entry];
	[self.navigationController pushViewController:entryController animated:YES];
	[entryController release];
}

@end
