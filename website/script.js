const updateVisitorCount = async () => {
    const spinner = document.getElementById('loadingSpinner');
    try {
        const url = 'https://cv-api.az.macro-c.com/api/getvisitor';
        
        // Get the count stored in session storage
        const storedCount = sessionStorage.getItem('currentVisitorCount');
        
        // Check if we need to fetch updated count from the API
        if (!storedCount) {
            spinner.style.display = 'block'; // Show spinner
            const response = await fetch(url);
            spinner.style.display = 'none'; // Hide spinner
            if (response.ok) {
                const data = await response.text();
                // Update the count displayed on the webpage
                document.getElementById('visitorCount').textContent = data;
                // Store the fetched count in session storage
                sessionStorage.setItem('currentVisitorCount', data);
            } else if (response.status = 429) {
                document.getElementById('visitorCount').textContent = "Rate Limit exceeded! 😮";
            } else {
                console.error('Failed to fetch visitor count:', response.statusText);
            }
        } else {
            // Display the count from session storage
            document.getElementById('visitorCount').textContent = storedCount;
        }
    } catch (error) {
        spinner.style.display = 'none'; // Hide spinner
        console.error('Error fetching visitor count:', error);
    }
};

document.addEventListener('DOMContentLoaded', updateVisitorCount);
